package sigma.core
{
    import flash.events.*;

    public class DataItem extends EventDispatcher 
	{
        protected var _readOnly:Boolean = false;
        protected var _parameters:String = "";
        protected var _source:String = "";
        protected var _item:String = "";
        protected var _connection:Connection = null;

        public function DataItem() 
		{
            _source = "";
            _item = "";
            _parameters = "";
            _readOnly = false;
            _connection = null;
            return;
        }// end function

        public function get item() : String {
            return _item;
        }// end function

        public function get source() : String {
            return _source;
        }// end function

        public function get connection() : Connection {
            return _connection;
        }// end function

        public function get readOnly() : Boolean {
            return _readOnly;
        }// end function

        public function set parameters(param1:String) : void {
            if (_readOnly){
                throw "parameters is readonly";
            }
            _parameters = param1;
            return;
        }// end function

        public function set item(param1:String) : void {
            if (_readOnly){
                throw "item is readonly";
            }
            _item = param1;
            return;
        }// end function

        public function get parameters() : String {
            return _parameters;
        }// end function

        public function set source(param1:String) : void {
            if (_readOnly){
                throw "item is readonly";
            }
            _source = param1;
            return;
        }// end function

        public function set connection(param1:Connection) : void {
            if (_readOnly){
                throw "item is readonly";
            }
            _connection = param1;
            return;
        }// end function

    }
}
