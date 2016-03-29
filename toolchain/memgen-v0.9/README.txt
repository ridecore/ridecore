Usage: ./memgen [-b] object-file-name memory-size[KB] > output-file-name

-b オプションをつけると生データを出力する．MMCカードに書き込む用．
つけない場合はcoeファイルを出力する．Block RAMに焼く用．
object-file-name はMieruPC向けのELFバイナリを指定する．
memory-size はメモリ量．現在のMieruPCでは52固定．

(2009-06-23 Updated)
-8 オプションをつけると8ビット単位でのcoeファイルを出力する．
MieruPC-byte用．