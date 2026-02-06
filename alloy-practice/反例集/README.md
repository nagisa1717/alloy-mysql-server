# 反例の説明

## 性質1に関して補足
alloy-rdb.alsでは，モデル化が妥当であるか確かめる指標として性質1の検査を目的としている．
ところで，`fact RecordUsesTableColumns`は一見してそこまで自明な内容ではない．
* `r.values.Value in { c : Column | c.table = r.table }`
この *in* に関しての説明をここで補足しておく．  
集合論理では，`「A in B」かつ「B in A」 `は`「A = B」`である．
ここで記述を逐語訳して噛み砕くと，  
* `r.values.Value in { c : Column | c.table = r.table }`は「valueがrの親となるTable以外のColmnと紐づかない」を保証する
* `{ c : Column | c.table = r.table } in r.values.Value`は「全てのcolmnに対応するValue(Null含む)がある」を保証する

意味を考えると，後者は`sig Record`の`values: Column -> one Value`の中身ですでに保証されているのものを冗長に意味している．  
したがって，意図的に重複を無くしたかったので *=* ではなく *in* にしている．  
あくまで補足的な内容にとどめるが，対象の基本的な構造および制約が妥当かは重要なので明記しておいた．
前者の性質は，この包含関係により保証されているので，inの左右を入れ替えると成立しない．
これは，`fact RecordUsesTableColumns`を`{ c : Column | c.table = r.table } in r.values.Value`のみ有効にしたときの検査で反例wrongRDB01を出されることにより確かめられる．
* wrongRDB01
  Table1はColmn0,Colmn1,Colmn2を列としてもつ．<br>
  Table0は列を持たないのに，Record0,Record1,Record2にColmn0,Colmn1,Colmn2それぞれに対応する値をとっている．

## 性質1に必要である制約(alloy-rdb.als参照)
元の定義 `sig Record { values: Column -> one Value }` から　　
`sig Record { values: Column -> lone Value }`に変更した時の検査では反例counter01が出力された．
* counter01　　
  Table上のRecordがColumn0とColumn1に対応する値を何もとっていない．（つまりは未定義状態）

## 性質2に必要である制約(alloy-primaryKey.als参照)
### 一意性制約の必要
`fact PrimaryKeyIsUnique`のみ，制約からなくした時の検査では反例counter02が出力された．
* counter02　　
  Tableの主キーpkはColmnであるのに，Record0とRecord1がColumnの対応として同じ値Valueをとっている．

### 非Null制約の必要
`fact PrimaryKeyIsNotNull`のみ，制約からなくした時の検査では反例counter03が出力された．
* counter03　　
  Tableの主キーpkはColmnであるのに，Record0とColumnの対応としてNullをとっている．

### ユニークキーとの関係
`assert UniqueKeyLookupReturnsOneExpectNull` は主キーの性質と同義のものをukに置き換えているだけである．　　
これの反例としてcounter04が出力されたが，これは上のounter03と全く同じ状況である．
* counter04　　
  Tableの主キーukはColmnであるのに，Record0とRecord1がColumnの対応として同じ値Valueをとっている．

したがってユニークキーの制約とは主キーから非Nullに関しての制約を無くしたものに他ならない．　　
ここで `assert UniqueKeyLookupReturnsOneExpectNull` のようにすれば反例は出なくなる．  
すなわちNullに関しては除外するという条件つきの性質とすれば，同様にレコードの一意性が性質として満たされる．

## 性質3に必要である制約(alloy-foreignKey.als参照)
### 参照先の存在制約の必要
`fact ForeignKeyValuesInPrimaryKey`を制約からなくした時の検査では反例counter05が出力された．
* counter05　　
  Tableが外部キーとしてColumn0とColumn1を持っているが(外部キーが複数あるのはOK)，Column0を参照先として主キーにもつテーブルが存在しない．

`fact ForeignKeyValuesInPrimaryKey`は，参照先テーブルの存在と，外部キー列中の全ての値が参照先の主キー列中に含まれることを同時に保証している．

### 参照先の値が主キー列中に含まれることの必要
`fact ForeignKeyValuesInPrimaryKey`を参照先の存在制約のみに弱めたのが `fact ForeignKeyHasOneReference` である．  
これのみ有効にした時の検査では反例counter06が出力された．
* counter06　　
  Colmn1を外部キーとしてもつTable1と,参照先としてColmn1を主キーにもつTable0が存在する．<br>
  しかしTable1のRecordではColmn1にValue0が対応しているのに対し，Table0のColmn1の列中にValue0は存在しない．
