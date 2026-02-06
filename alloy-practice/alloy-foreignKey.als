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
  pk: lone Column,
  fk: set Column
}


///////////ここからPrimaryKeyについて///////////

fact PrimaryKeyIsNotNull {
  all r: Record |
    r.values[r.table.pk] != Null
}

fact PrimaryKeyIsUnique {
  all r1, r2: Record |
    r1.table = r2.table && r1 != r2 implies
      r1.values[r1.table.pk] = Null or
      r2.values[r1.table.pk] = Null or
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
fact ForeignKeyExists {
	all t: Table | some t.fk
}

fact ForeignKeyIsNotPrimaryKey {
	all t: Table |
		t.pk != t.fk
}

//fact ForeignKeyHasValue { 自明？
//  all r: Record |
//    some r.values[r.table.fk]
//}


//fact ForeignKeyHasOneReference { //弱い制約
//  all t1: Table |
//    some t1.fk implies
//      one t2: Table | t2.pk = t1.fk
//}

fact ForeignKeyConstraint {
  all t1: Table |
	some t1.fk implies
		some t2: Table |
			t2.pk = t1.fk and
			(t1.~table).values[t1.fk] in (t2.~table).values[t2.pk]
}

fact ForeignKeyValuesInPrimaryKey {
  all r: Record |
    some r.table.fk implies
      let fkCol = r.table.fk |
        let v = r.values[fkCol] |
          v = Null or
	   v in (fkCol.table.~table).values[fkCol.table.pk]
}

assert ForeignKeyLookupReturnsOneRecord {
  all r: Record |
    some r.table.fk
    and r.values[r.table.fk] not in Null
    implies
      one lookupRecordByPrimaryKey[
        r.table.fk.table,
        r.values[r.table.fk]
      ]
}

check ForeignKeyLookupReturnsOneRecord for 3
