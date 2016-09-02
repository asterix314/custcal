/********************************************
    业务摘要：  940013
    业务名称：  三方存管加银行-
    动作代码：  -
    流通类型：  -
********************************************/
if exists (select * from sysobjects where type='P' and name= 'sp_Cust_ZZCQ_Sfcgpm' )
    drop proc sp_Cust_ZZCQ_Sfcgpm
go

CREATE proc sp_Cust_ZZCQ_Sfcgpm(
 @serverid  char(1)      
,@bizdate   int          
,@sno       int
,@custid    bigint    
,@msg       varchar(128) =null output)
with encryption
as
-- do nothing
GO

