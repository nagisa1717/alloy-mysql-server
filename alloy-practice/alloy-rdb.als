//一般的なRDBの構造定義および制約

//ベースの定義；テーブル，レコード，列，値
//sig Table {}
sig Column { table: one Table }
sig Record {
	table: one Table,
	values: Column -> lone Value
}
sig Value {}
one sig Null extends Value {}

//構造制約；レコードの値が紐ずくカラムはテーブルに定義されているカラムに含まれる必要がある
//1. 全てのcolmnに対応するValue(null含む)がある
//2. 親となるTable以外のcolmnを参照しない
fact RecordUsesTableColumns { 
	all r : Record |
		r.values.Value = { c : Column | c.table = r.table }
		//r.values.Value in { c : Column | c.table = r.table }	: 1を保証しない
		//{ c : Column | c.table = r.table } in r.values.Value	: 2を保証しない
}

//主キー制約
sig Table {
  pk: lone Column
}

fact PrimaryKeyIsColumnOfTable {
  all t: Table |
    t.pk.table = t
}
fact PrimaryKeyIsNotNull {
  all r: Record |
    r.values[r.table.pk] != Null
}

fact PrimaryKeyIsUnique {
  all r1, r2: Record |
    r1.table = r2.table && r1 != r2 implies
      r1.values[r1.table.pk] != r2.values[r2.table.pk]
}

fun lookupValue[r: Record, c: Column]: lone Value {
  { v: Value |
    c.table = r.table
    and v in c.(r.values)
  }
}

fun lookupRecordByPrimaryKey[t: Table, v: Value]: set Record {
  { r: Record |
      r.table = t
      and some pk: t.pk |
          pk.(r.values) = v
  }
}

assert PrimaryKeyLookupReturnsOne {
  all r: Record |
    one lookupValue[r, r.table.pk]
    and one lookupRecordByPrimaryKey[
      r.table,
      lookupValue[r, r.table.pk]
    ]
}

//run Table {}
check PrimaryKeyLookupReturnsOne for 5