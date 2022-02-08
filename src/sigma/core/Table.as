package sigma.core
{

    public class Table extends RequestableDataItem 
	{
        private var columns:Array;
        private var rows:Array;

        public function Table() 
		{
            rows = new Array();
            columns = new Array();
            type = DataItemType.Table;
            format = DataFormat.Table;
            return;
        }

        public function getCellValue(param1:int, param2:int) : String 
		{
            var _loc_3:TableRow = null;
            var _loc_4:TableCell = null;
            _loc_3 = rows[param1];
            if (_loc_3 == null)
			{
                return "";
            }
            _loc_4 = _loc_3.cells[param2];
            if (_loc_4 == null)
			{
                return "";
            }
            return _loc_4.value;
        }// end function

        private function addRow(param1:String) : TableRow 
		{
            var _loc_2:TableRow = null;
            var _loc_3:int = 0;
            _loc_2 = new TableRow();
            _loc_2.index = rows.length;
            rows.push(_loc_2);
            if (param1 != null){
                _loc_2.name = param1;
            }
            _loc_3 = 0;
            while (_loc_3 < columns.length){
                
                _loc_2.cells.push(new TableCell());
                _loc_3 = _loc_3 + 1;
            }
            dispatchEvent(new TableEvent(TableEvent.ADD_ROW));
            return _loc_2;
        }// end function

        private function selectColumn(param1:int) : TableColumn {
            while (param1 >= columns.length){
                
                addColumn("");
            }
            return columns[param1];
        }// end function

        public function getUserData(param1:int, param2:int) : String {
            var _loc_3:TableRow = null;
            var _loc_4:TableCell = null;
            _loc_3 = rows[param1];
            if (_loc_3 == null)
			{
                return "";
            }
            _loc_4 = _loc_3.cells[param2];
            if (_loc_4 == null)
			{
                return "";
            }
            return _loc_4.userData;
        }// end function

        private function deleteColumn(param1:int) : void 
		{
            var _loc_2:TableRow = null;
            var _loc_3:int = 0;
            dispatchEvent(new TableSetEvent(TableSetEvent.DELETE_COLUMN, param1));
            columns.splice(param1, 1);
            for each (_loc_2 in rows)
			{
                
                _loc_2.cells.splice(param1, 1);
            }
            _loc_3 = param1;
            while (_loc_3 < columns.length)
			{
                
                TableColumn(columns[_loc_3]).index = _loc_3;
                _loc_3 = _loc_3 + 1;
            }
            return;
        }// end function

        private function setUserData(param1:TableRow, param2:TableColumn, param3:String) : void {
            var _loc_4:TableCell = null;
            /*if (param1 != null){
            }*/
			
            if (param1 == null || param2 == null){
                return;
            }
            _loc_4 = TableCell(param1.cells[param2.index]);
            if (_loc_4 == null)
			{
                return;
            }
            _loc_4.userData = param3;
            dispatchEvent(new TableCellEvent(TableCellEvent.SET_USERDATA, param1.index, param2.index));
            return;
        }// end function

        private function moveRow(param1:TableRow, param2:String) : void 
		{
            var _loc_3:int = 0;
            var _loc_4:int = 0;
            var _loc_5:int = 0;
            var _loc_6:int = 0;
			
            if (param1 == null)
			{
                return;
            }
			
            _loc_3 = param1.index;
            _loc_4 = parseInt(param2);
            
            if (!(_loc_4 >= 0 &&_loc_4 < rows.length) || _loc_4 == _loc_3)
			{
				return;
            }			
            dispatchEvent(new TableMoveEvent(TableMoveEvent.MOVING_ROW, _loc_3, _loc_4));
            rows.splice(_loc_4, 0, rows[_loc_3]);
            _loc_5 = _loc_3;
            if (_loc_4 < _loc_3)
			{
                _loc_5 = _loc_5 + 1;
            }
            rows.splice(_loc_5, 1);
            _loc_6 = Math.min(_loc_5, _loc_4);
            while (_loc_6 < rows.length)
			{
                
                rows[_loc_6].index = _loc_6;
                _loc_6 = _loc_6 + 1;
            }
            dispatchEvent(new TableMoveEvent(TableMoveEvent.MOVED_ROW, _loc_3, _loc_4));            
        }

        private function deleteAllColumns() : void 
		{
            var _loc_1:TableRow = null;
            dispatchEvent(new TableEvent(TableEvent.DELETE_ALL_COLUMNS));
            columns = new Array();
            for each (_loc_1 in rows)
			{
                
                _loc_1.cells = new Array();
            }
            return;
        }// end function

        private function setColumnName(param1:TableColumn, param2:String) : void {
            if (param1 == null){
                return;
            }
            param1.name = param2;
            dispatchEvent(new TableSetEvent(TableSetEvent.SET_COLUMN_NAME, param1.index));
            return;
        }// end function

        override public function onMessage(param1:Message) : void {
            var _loc_2:Boolean = false;
            switch(param1.type){
                case MessageType.Image:
                case MessageType.Update:{
                    if (status != DataState.Live){
                        setStatus(DataState.Live, DataError.None, "");
                    }
                    _loc_2 = param1.type == MessageType.Image;
                    dispatchEvent(new DataItemUpdateEvent(DataItemUpdateEvent.BEGIN, _loc_2));
                    if (_loc_2){
                        clear();
                    }
                    decodeMessage(param1);
                    dispatchEvent(new DataItemUpdateEvent(DataItemUpdateEvent.END, _loc_2));
                    break;
                }
                default:{
                    super.onMessage(param1);
                    break;
                }
            }
            return;
        }// end function

        private function moveColumn(param1:TableColumn, param2:String) : void 
		{
            var _loc_3:int = 0;
            var _loc_4:int = 0;
            var _loc_5:TableRow = null;
            var _loc_6:int = 0;
            var _loc_7:int = 0;
			
            if (param1 == null)
			{
                return;
            }
			
            _loc_3 = param1.index;
            _loc_4 = parseInt(param2);
          
            if ( !(_loc_4 >= 0 && _loc_4 < columns.length ) || _loc_4 == _loc_3 )
			{
                return;
            }
            dispatchEvent(new TableMoveEvent(TableMoveEvent.MOVING_COLUMN, _loc_3, _loc_4));
            for each (_loc_5 in rows)
			{
                
                _loc_5.cells.splice(_loc_4, 0, _loc_5.cells[_loc_3]);
            }
            columns.splice(_loc_4, 0, columns[_loc_3]);
            _loc_6 = _loc_3;
			
            if (_loc_4 < _loc_3)
			{
                _loc_6 = _loc_6 + 1;
            }
            _loc_7 = Math.min(_loc_4, _loc_6);
            while (_loc_7 < columns.length)
			{
                
                TableColumn(columns[_loc_7]).index = _loc_7;
                _loc_7 = _loc_7 + 1;
            }
            deleteColumn(_loc_6);
            dispatchEvent(new TableMoveEvent(TableMoveEvent.MOVED_COLUMN, _loc_3, _loc_4));
           
        }

        public function getColumnType(param1:int) : DataType {
            var _loc_2:TableColumn = null;
            _loc_2 = columns[param1];
            if (_loc_2 == null)
			{
                return DataType.None;
            }
            return _loc_2.type;
        }// end function

        protected function decodeMessage(param1:Message) : Boolean {
            var _loc_2:TableColumn = null;
            var _loc_3:TableRow = null;
            var _loc_4:MessageField = null;
            var _loc_5:int = 0;
            var _loc_6:String = null;
            _loc_2 = null;
            _loc_3 = null;
            for each (_loc_4 in param1.body)
			{
                
                _loc_5 = _loc_4.key;
                _loc_6 = _loc_4.value;
                /*if (_loc_6.length > 1){
                }*/
                if (_loc_6.length > 1 && _loc_6.charAt(0) == "\"")
				{
                    _loc_6 = _loc_6.substring(1, (_loc_6.length - 1));
                }
                if (_loc_5 >= TableOpCode.SetCell)
				{
                    _loc_2 = selectColumn(_loc_5 - TableOpCode.SetCell);
                    setCell(_loc_3, _loc_2, _loc_6);
                    continue;
                }
				
                switch(_loc_5)
				{
                    case TableOpCode.AddColumn:
					{
                        _loc_2 = addColumn(_loc_6);
                        break;
                    }
                    case TableOpCode.SetColumnName:
					{
                        setColumnName(_loc_2, _loc_6);
                        break;
                    }
                    case TableOpCode.SetColumnType:
					{
                        setColumnType(_loc_2, _loc_6);
                        break;
                    }
                    case TableOpCode.SelectColumn:
					{
                        _loc_2 = selectColumnByString(_loc_6);
                        break;
                    }
                    case TableOpCode.DeleteColumn:
					{
                        deleteColumnByString(_loc_6);
                        _loc_2 = null;
                        break;
                    }
                    case TableOpCode.DeleteAllColumns:
					{
                        deleteAllColumns();
                        _loc_2 = null;
                        break;
                    }
                    case TableOpCode.MoveColumn:
					{
                        moveColumn(_loc_2, _loc_6);
                        break;
                    }
                    case TableOpCode.AddRow:
					{
                        _loc_3 = addRow(_loc_6);
                        break;
                    }
                    case TableOpCode.SetRowName:
					{
                        setRowName(_loc_3, _loc_6);
                        break;
                    }
                    case TableOpCode.SelectRow:
					{
                        _loc_3 = selectRow(_loc_6);
                        break;
                    }
                    case TableOpCode.DeleteRow:
					{
                        deleteRow(_loc_6);
                        _loc_3 = null;
                        break;
                    }
                    case TableOpCode.DeleteAllRows:
					{
                        deleteAllRows();
                        _loc_3 = null;
                        break;
                    }
                    case TableOpCode.MoveRow:
					{
                        moveRow(_loc_3, _loc_6);
                        break;
                    }
                    case TableOpCode.SetUserData:
					{
                        setUserData(_loc_3, _loc_2, _loc_6);
                        break;
                    }
                    default:
					{
                        break;                        
                    }
                }
            }
            return true;
        }// end function

        private function selectRow(param1:String) : TableRow {
            var _loc_2:int = 0;
            _loc_2 = parseInt(param1);
            while (_loc_2 >= rows.length)
			{
                
                addRow("");
            }
            return rows[_loc_2];
        }// end function

        private function setRowName(param1:TableRow, param2:String) : void {
            if (param1 == null)
			{
                return;
            }
            if (param2 != null)
			{
                param1.name = param2;
            }
            dispatchEvent(new TableSetEvent(TableSetEvent.SET_ROW_NAME, param1.index));
            return;
        }// end function

        public function getRowCount() : int 
		{
            return rows.length;
        }// end function

        public function getRowName(param1:int) : String {
            var _loc_2:TableRow = null;
            _loc_2 = rows[param1];
            if (_loc_2 == null){
                return "";
            }
            return _loc_2.name;
        }// end function

        private function deleteColumnByString(param1:String) : void {
            var _loc_2:int = 0;
            _loc_2 = parseInt(param1);
            deleteColumn(_loc_2);
            return;
        }// end function

        private function addColumn(param1:String) : TableColumn {
            var _loc_2:TableColumn = null;
            var _loc_3:TableRow = null;
            _loc_2 = new TableColumn();
            _loc_2.type = DataType.None;
            _loc_2.index = columns.length;
            columns.push(_loc_2);
            if (param1 != null){
                _loc_2.name = param1;
            }
            for each (_loc_3 in rows){
                
                _loc_3.cells.push(new TableCell());
            }
            dispatchEvent(new TableEvent(TableEvent.ADD_COLUMN));
            return _loc_2;
        }// end function

        private function setColumnType(param1:TableColumn, param2:String) : void {
            if (param1 == null){
                return;
            }
            param1.type = DataType.fromInt(parseInt(param2));
            dispatchEvent(new TableSetEvent(TableSetEvent.SET_COLUMN_TYPE, param1.index));
            return;
        }// end function

        public function findRow(param1:String) : int {
            var _loc_2:TableRow = null;
            for each (_loc_2 in rows){
                
                if (_loc_2.name == param1){
                    return _loc_2.index;
                }
            }
            return -1;
        }// end function

        private function clear() : void {
            deleteAllRows();
            deleteAllColumns();
            return;
        }// end function

        public function get columnCount() : int {
            return columns.length;
        }// end function

        private function selectColumnByString(param1:String) : TableColumn {
            var _loc_2:int = 0;
            _loc_2 = parseInt(param1);
            return selectColumn(_loc_2);
        }// end function

        private function setCell(param1:TableRow, param2:TableColumn, param3:String) : void {
            var _loc_4:TableCell = null;
            if (param1 == null || param2 == null)
			{
				return;
            }
            
            _loc_4 = TableCell(param1.cells[param2.index]);
            if (_loc_4 == null){
                _loc_4 = new TableCell();
            }
            _loc_4.value = param3;
            dispatchEvent(new TableCellEvent(TableCellEvent.SET_CELL, param1.index, param2.index));
            return;
        }// end function

        public function findColumn(param1:String) : int {
            var _loc_2:TableColumn = null;
            for each (_loc_2 in columns){
                
                if (_loc_2.name == param1){
                    return _loc_2.index;
                }
            }
            return -1;
        }// end function

        private function deleteRow(param1:String) : void {
            var _loc_2:int = 0;
            var _loc_3:int = 0;
            _loc_2 = parseInt(param1);
            rows.splice(_loc_2, 1);
            _loc_3 = _loc_2;
            while (_loc_3 < rows.length){
                
                TableRow(rows[_loc_3]).index = _loc_3;
                _loc_3 = _loc_3 + 1;
            }
            dispatchEvent(new TableSetEvent(TableSetEvent.DELETE_ROW, _loc_2));
            return;
        }// end function

        private function deleteAllRows() : void {
            dispatchEvent(new TableEvent(TableEvent.DELETE_ALL_ROWS));
            rows = new Array();
            return;
        }// end function

        public function getColumnName(param1:int) : String {
            var _loc_2:TableColumn = null;
            _loc_2 = columns[param1];
            if (_loc_2 == null){
                return "";
            }
            return _loc_2.name;
        }// end function

    }
}
