CREATE FUNCTION [dbo].[Fn_FormatXmlString](@vDelimeter Char(2), @vInputString AS Varchar(MAX) )
RETURNS
      @Result TABLE(Value VARCHAR(MAX))
AS

BEGIN

      DECLARE @str VARCHAR(MAX)

      DECLARE @ind Int

      IF(@vInputString is not null)

      BEGIN

            SET @ind = CharIndex(@vDelimeter,@vInputString)

            WHILE @ind > 0

            BEGIN

                  SET @str = SUBSTRING(@vInputString,1,@ind)

                  SET @vInputString = SUBSTRING(@vInputString,@ind+1,LEN(@vInputString)-@ind)

                  INSERT INTO @Result values (@str)

                  SET @ind = CharIndex(@vDelimeter,@vInputString)

            END

            SET @str = @vInputString

            INSERT INTO @Result values (@str)

      END

      RETURN

END


