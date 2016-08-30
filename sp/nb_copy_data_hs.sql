if exists (select * from sysobjects where type='P' and name='nb_copy_data_hs')
    drop proc nb_copy_data_hs
go
create proc nb_copy_data_hs(  
 @source     varchar(64)          --源表名  
,@dest       varchar(64)          --目标表名  
,@backdate   int           =null  --日期数据  为空则为所有  
,@msg        varchar(128)  =null  output  
)  
as  
declare @des_strsql as varchar(2000), @source_strsql as varchar(2000), @des_colname as varchar(64), @source_colname as varchar(64)
   select @des_strsql='', @source_strsql=''
  
   declare cur_tt cursor for  
   select a.name, desname=case when b.name is null then '0' else b.name end
     from   
            ( select c1.colid, c1.name 
                from sysobjects s1, syscolumns c1  
               where s1.xtype='U' and s1.name=@dest and s1.id=c1.id) as a
   left join           
            ( select c2.colid, c2.name 
                from sysobjects s2, syscolumns c2  
               where s2.xtype='U' and s2.name=@source and s2.id=c2.id) as b  
         on a.name=b.name   
   order by a.colid   
     
   open cur_tt  
   fetch cur_tt into @des_colname, @source_colname
   while (@@fetch_status=0)  
   begin  
      select @des_strsql=@des_strsql+@des_colname+','  
      select @source_strsql=@source_strsql+@source_colname+','        
      fetch cur_tt into @des_colname, @source_colname
   end       
   close cur_tt  
   deallocate cur_tt     
     
   if (@des_strsql='')  --无匹配字段  
       begin  
          select @msg='-1 源和目标数据表没有共同字段或表不存在 ('+@source+','+@dest+')'  
          return -1   
       end  
     else  
       begin  
          select @des_strsql=left(@des_strsql,len(@des_strsql)-1), @source_strsql=left(@source_strsql,len(@source_strsql)-1)    
       end  
  
   if (@backdate is null)
       begin
          select @des_strsql='insert '+@dest+'('+@des_strsql+') select '+@source_strsql+' from '+@source
       end
    else
       begin
          select @des_strsql='insert '+@dest+'('+@des_strsql+') select '+@source_strsql+' from '+@source+' where backdate='+convert(varchar, @backdate)  
       end

   begin try  
      begin tran   
         exec ('delete '+@dest)  
         exec (@des_strsql)  
  
      commit tran  
      select @msg='0 源和目标数据表复制成功 ('+@source+','+@dest+')'  
      return 0  
   end try  
   begin catch  
      if (@@trancount>0)  
          rollback tran  
  
      select @msg='-1 源和目标数据表复制时出现错误 ('+@source+','+@dest+'):['+error_message()+']'  
      return -1  
   end catch  
go