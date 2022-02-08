package sigma.core
{

    public class DataItemWithStatus extends DataItem implements IRequestEvents {
        private var _errorMessage:String = "";
        private var _dataState:DataState;
        private var _dataError:DataError;

        public function DataItemWithStatus() 
		{
            _dataState = DataState.Closed;
            _dataError = DataError.None;
            _errorMessage = "";
            return;
        }// end function

		public function setStatus(param1:DataState, param2:DataError, param3:String) : void 
		{           
            _dataState = param1;           
            _dataError = param2;           
            _errorMessage = param3;
            onStatusChanged();
            return;
        }// end function

        public function get statusError() : DataError 
		{
            return _dataError;
        }// end function

        private function onStatusChanged() : void 
		{
            dispatchEvent(new DataItemStateEvent(DataItemStateEvent.STATE, _dataState, _dataError, _errorMessage));
            return;
        }// end function

        public function onMessage(param1:Message) : void 
		{
            switch(param1.type)
			{
                case MessageType.Status:
				{
                    param1.getIntByKey(DataKey.State, int(DataState.Live));
                    param1.getIntByKey(DataKey.Error, int(DataError.None));
                    if (_dataError == DataError.None)
					{                       
                        _errorMessage = "";
                    }
                    onStatusChanged();
                    break;
                }
                case MessageType.Error:
				{
                    var _loc_3:* = DataState.Closed;
                    _dataState = DataState.Closed;
                    param1.getIntByKey(DataKey.Error, int(DataError.None));                    
                    _errorMessage = param1.getStringByKey(DataKey.Text, "");
                    onStatusChanged();
                    break;
                }
                default:{
                    break;
                }
            }
            return;
        }// end function

        public function get statusErrorMessage() : String {
            return _errorMessage;
        }// end function

        public function get status() : DataState {
            return _dataState;
        }// end function

    }
}
