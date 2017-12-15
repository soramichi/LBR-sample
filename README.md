[[English]](https://github.com/soramichi/LBR-sample/blob/master/README.en.md)

# LBR (Last Branch Record) を使うサンプル

## LBR の概要
- プロセッサがブランチ関連命令を実行した時のジャンプ元（from_ip）とジャンプ先（to_ip）を記録
- ブランチにはjmpだけではなく関数呼び出しやretなども含む。
- ハードウェアでレジスタに保存するためオーバーヘッドが（ほぼ）ゼロ
- 一方 gdb などでも使われている branch trace はブランチのたびに割り込みをかけてソフトウェアで保存するためオーバーヘッドが大きい（手元の実験では数値計算アプリの速度が250倍低下した）
- ただしレジスタに保存するため一定個数しか保存できない。Skylake以降では32個、それ以前では16個保存される。

## サンプルの使い方
- ひたすらjmpしまくるプログラムを用意
```
main(){
  int i = 0;

  while(1) {
      i++;
  }
}
```
- 特定のコア（例えばコア1）にpinして実行
```
$ taskset -c 1 ./a.out &
```
- サンプルを実行（コア1の from_ip を読んで表示）
```
$ ./lastbranch_from_ip.sh
559135ada66f
559135ada66f
559135ada66f
...
```
- a.out の maps (/proc/{PID}/maps) からコードが配置されているアドレスを見て、コード中のjmp命令があるオフセットを足すと上で出た値と同じになっていることが確認できる

## 注意
- LBRは C-state が2以上になると消えてしまい、かつ消えるのを抑制する設定はない。従ってプログラムを終了した後でLBRを読みたければ C-state が2以上にならないようにする。具体的には `/etc/default/grub` の `GRUB_CMDLINE_LINUX` に `intel_idle.max_cstate=1 intel_pstate=disable` を追加し、`sudo update-grub` を実行する。

## 課題点
- gdbの中にLBRを使う機能はない。これはブレイクポイントや例外発生時にLBRの更新を止めるという機能がCPUにないため。つまり例外発生時にgdbからLBRを見るとプログラムからgdbに遷移するbranchなどで埋まってしまう。
- したがってSIGFPEなどの任意の例外が発生した時にLBRの更新を止めるには、OSの例外ハンドラの頭にLBRをストップさせるコード（レジスタへの書き込み）を追加する必要がある。

## 参考情報
- https://lwn.net/Articles/680985/
- https://lwn.net/Articles/680996/ 