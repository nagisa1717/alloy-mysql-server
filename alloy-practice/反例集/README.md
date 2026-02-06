# 反例の説明

## 性質1に関して
性質1は，モデル化が妥当であるか確かめる指標として
ところで，RecordUsesTableColumnsは一見して定義から自明な内容ではない．
* `r.values.Value *in* { c : Column | c.table = r.table }`
