if exists(select * from sysobjects where xtype='FN' and name='F_GetLogassetOrder')
   drop function F_GetLogassetOrder
go
create function F_GetLogassetOrder(
 @digestid      int
,@stkeffect     numeric(20,2) 
) returns int
as
begin
   return case when @digestid=220000 then 0           --买入
               when @digestid=221001 then 90          --卖出
               
               when @digestid=220039 then 23           --ETF赎回增股    
               when @digestid=221036 then 24           --ETF申购减股
               when @digestid=220038 then 25           --ETF申购增股
               when @digestid=221037 then 26           --ETF赎回减股    

               when @digestid=220056 then 27           --开放基金拆分增股
               when @digestid=221056 then 29           --开放基金合并减股
               
               when @digestid=220057 then 30           --开放基金合并增股
               when @digestid=221057 then 28           --开放基金拆分减股
               
               when @stkeffect>=0    then 10           --其余增加类
                                     else 60           --剩余减少类
          end
end              
go
    