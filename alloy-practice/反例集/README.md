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

意味を考えると，後者は`sig Record`の`values: Column -> one Value`の中身ですでに保証されているのである．  
したがって，意図的に重複を無くしたかったので *=* ではなく *in* にしている．  
あくまで補足的な内容にとどめるが，対象の基本的な構造および制約が妥当かは重要なので明記しておいた．
前者の性質は，この包含関係により保証されているので，inの左右を入れ替えると成立しなくなることを後の検証で示している．
