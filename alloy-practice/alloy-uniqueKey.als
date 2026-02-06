//一般的なRDBの構造定義および制約

sig Column { table: one Table }
sig Record {
	table: one Table,
	values: Column -> one Value
}
sig Value {}
one sig Null extends Value {}

fact RecordUsesTableColumns { 
	all r : Record |
		r.values.Value in { c : Column | c.table = r.table }
}

sig Table {
  uk: set Column
}

///////////ここからUniqueKeyについて///////////

//PrimarkKeyとの違い：Nullを取りえるか
//fact PrimaryKeyIsNotNull {
//  all r: Record |
//    r.values[r.table.pk] != Null
//}

fact UniqueKeyConstraint {
  all r1, r2: Record |
    r1.table = r2.table && r1 != r2 implies
      r1.values[r1.table.uk] = Null or
      r2.values[r1.table.uk] = Null or
      r1.values[r1.table.uk] != r2.values[r2.table.uk]
}

fact UniqueKeyExists { //テーブルが1つのukを持つと仮定．
	all t: Table | one t.uk
}

fun lookupValue[r: Record, c: Column]: lone Value {
  { v: Value |
    c.table = r.table
    and v in c.(r.values)
  }
}

fun lookupRecordByUniqueKey[t: Table, v: Value]: set Record {
  { r: Record |
      r.table = t
      and some uk: t.uk |
          uk.(r.values) = v
  }
}

//これは成り立たない
//assert UniqueKeyLookupReturnsOne {
//  all r: Record |
//    one lookupValue[r, r.table.uk]
//    and one lookupRecordByUniqueKey[
//      r.table,
//      lookupValue[r, r.table.uk]
//    ]
//}

//条件を弱めれば成り立つ
assert UniqueKeyLookupReturnsOneExpectNull {
  all r: Record |
    let v = lookupValue[r, r.table.uk] |
      (v not in Null) implies
        one lookupRecordByUniqueKey[r.table, v]
}

check UniqueKeyLookupReturnsOneExpectNull for 5
