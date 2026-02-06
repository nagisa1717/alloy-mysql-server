//一般的なRDBの構造定義および制約

//ベースの定義；テーブル，レコード，列，値
sig Table {}
sig Column { table: one Table }
sig Record {
	table: one Table,
	values: Column -> one Value
}
sig Value {}
one sig Null extends Value {}

//構造制約；レコードrが持つ値が紐ずく列集合と，rと同テーブルに定義されている列集合は一致する
//1. 全てのcolmnに対応するValue(null含む)がある -> sigと重複するので冗長
//2. valueがrの親となるTable以外のcolmnと紐づかない
fact RecordUsesTableColumns { 
	all r : Record |
		//r.values.Value = { c : Column | c.table = r.table }
		r.values.Value in { c : Column | c.table = r.table }
		//{ c : Column | c.table = r.table } in r.values.Value	//: 2を保証しない
}

fun lookupValue[r: Record, c: Column]: lone Value {
  { v: Value |
    c.table = r.table
    and v in c.(r.values)
  }
}

assert ValueIsDecisivePerRecordAndColumn {
  all r: Record, c: Column |
    r.table = c.table implies
      one lookupValue[r, c]
}

//run Table {}
check ValueIsDecisivePerRecordAndColumn for 5
