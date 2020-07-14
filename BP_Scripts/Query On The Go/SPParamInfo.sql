SELECT

   'Procedure_Name' = procedures.name,
   'Parameter_Name' = parameters.name,  
   'Type'   = type_name(user_type_id),  
   'Length'   = max_length,  
   'Prec'   = case when type_name(system_type_id) = 'uniqueidentifier' 
              then precision  
              else OdbcPrec(system_type_id, max_length, precision) end,  
   'Scale'   = OdbcScale(system_type_id, scale),  
   'Param_order'  = parameter_id,  
   'Collation'   = convert(sysname, 
                   case when system_type_id in (35, 99, 167, 175, 231, 239)  
                   then ServerProperty('collation') end)  

  from sys.parameters INNER JOIN sys.procedures On parameters.object_id = procedures.object_id
  where parameters.object_id IN(SELECT object_id from sys.procedures where name IN(SELECT Edit_Tag_Upd_SP_Name FROM GPM_Admin_Tags_Edit_Details))
  

/*
select procedures.name,parameters.name,parameters.max_length from sys.parameters 
inner join sys.procedures on parameters.object_id = procedures.object_id 
inner join sys.types on parameters.system_type_id = types.system_type_id AND parameters.user_type_id = types.user_type_id
where procedures.name like 'Sp_%'
*/