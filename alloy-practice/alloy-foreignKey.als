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
		r.values.Value = { c : Column | c.table = r.table }
}

sig Table {	//一個以上持つと仮定
  pk: lone Column,
  fk: some Column
}

fact EachTableHasRecord {  //一個以上recordを持つと仮定
  all t: Table | some r: Record | r.table = t
}

///////////ここからPrimaryKeyについて///////////

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

fact PrimaryKeyExists {
	all t: Table | one t.pk
}


fun lookupRecordByPrimaryKey[t: Table, v: Value]: set Record {
  { r: Record |
      r.table = t
      and some pk: t.pk |
          pk.(r.values) = v
  }
}

///////////ここからForeignKeyについて///////////

fact ForeignKeyIsNotPrimaryKey {
	all t: Table |
		t.pk != t.fk
}

fact ForeignKeyHasValue {
  all r: Record |
    some r.values[r.table.fk]
}

//fact ForeignKeyHasOneReference {
//  all t1: Table |
//    some t1.fk implies
//      one t2: Table | t2.pk = t1.fk
//}

fact ForeignKeyConstraint {
  all r: Record |
    some r.table.fk implies
      let fkCol = r.table.fk |
        let v = r.values[fkCol] |
          v in Null
          or
          some r2: Record |
            r2.table = fkCol.table
            and r2.values[r2.table.pk] = v
}

assert ForeignKeyLookupReturnsSome {
  all r: Record |
    some r.table.fk
    and r.values[r.table.fk] not in Null
    implies
      one lookupRecordByPrimaryKey[
        r.table.fk.table,
        r.values[r.table.fk]
      ]
}

check ForeignKeyLookupReturnsSome for 10