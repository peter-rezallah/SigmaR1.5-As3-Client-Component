package sigma.core
{

    public final class TableOpCode extends Object 
	{        
       
		/* ************* COL *********** */
        public static const AddColumn:int = 1;
		public static const SetColumnType:int = 2;
		public static const SetColumnName:int = 3;
		public static const SelectColumn:int = 4;
		public static const DeleteColumn:int = 5;
		public static const DeleteAllColumns:int = 6;
		public static const MoveColumn:int = 7;
		/* ************* ROW *********** */
		public static const AddRow:int = 8;
		public static const SetRowName:int = 9;
		public static const SelectRow:int = 10;
		public static const DeleteRow:int = 11;		
		public static const DeleteAllRows:int = 12;
		public static const MoveRow:int = 13;
        public static const SetUserData:int = 14;
		
		public static const SetCell:int = 32;
		

        function TableOpCode() 
		{
        }

    }
}
