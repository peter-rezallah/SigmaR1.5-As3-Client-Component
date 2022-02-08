package sigma.core
{	

  public class Source extends DataItem implements IRequestEvents 
	{
        private var _mountResult:DataError;
        private var requestId:int = 0;

        public function Source() : void 
		{
            requestId = 0;
            _mountResult = DataError.None;
            return;
        }// end function

        private function onContribute(param1:Message) : void 
		{
            return;
        }// end function

        public function get mountResult() : DataError {
			
            return _mountResult;
        }// end function

        private function fireMountResult(param1:DataError) : void 
		{
            _mountResult = param1;
            dispatchEvent(new SourceMountEvent(SourceMountEvent.RESULT, param1));
            return;
        }// end function

        public function sendStatus(param1:String, param2:String, param3:DataState, param4:DataError, param5:String) : Boolean 
		{
            var msg:Message = null;
            
            if (requestId && _mountResult != DataError.None)
			{
                return false;
            }			
           
            if (param3 != DataState.Live && param3 == DataState.Pending && param4 != DataError.None)
			{
                return false;
            }
			msg = new Message();
			msg.type = MessageType.Status;
			msg.addString(DataKey.Source, source);
			msg.addString(DataKey.Item, param1);
			msg.addString(DataKey.Params, param2);
			msg.addInt(DataKey.State, int(param3));
			msg.addInt(DataKey.Error, int(param4));
			msg.addString(DataKey.Text, param5);
            _connection.send(msg);
            return true;
        }// end function

        public function mount() : Boolean 
		{
            var msg:Message = null;
            unmount();
            
            if (_connection && source == "")
			{
                fireMountResult(DataError.InvalidSource);
                return false;
            }
			msg = new Message();
			msg.type = MessageType.Mount;
			msg.addString(DataKey.Source, source);
			/* my code */
			msg.addString(DataKey.Params, _parameters);
			msg.addString(DataKey.Conflation , _connection.conflation.toString() );
			/* ------- */
            requestId = _connection.openRequest(msg, this);
            return true;
        }// end function

        public function onMessage(param1:Message) : void 
		{
            var _loc_2:DataError = null;
            switch(param1.type)
			{
                case MessageType.Subscribe:
                case MessageType.Unsubscribe:
				{
                    onSubscribe(param1);
                    break;
                }
                case MessageType.Error:
				{
                    _loc_2 = DataError.fromInt(param1.getIntByKey(int(DataKey.Error), int(DataError.None)));
                    if (_loc_2 != DataError.None)
					{
                        unmount();
                    }
                    fireMountResult(_loc_2);
                    break;
                }
                case MessageType.Status:
                case MessageType.Image:
                case MessageType.Update:
				{
                    onContribute(param1);
                    break;
                }
                default:
				{
                    break;
                   
                }
            }
            return;
        }// end function

        private function onSubscribe(param1:Message) : void 
		{
			trace("/*/*/*/*/*/*/*/*/*/ SUBSCRIBE */*/*/*/*/*/*/*" + param1.type );
            var subscribeFlag:Boolean = false;
            var source:String = null;
            var item:String = null;
            var params:String = null;
			subscribeFlag = param1.type == MessageType.Subscribe;
			source = param1.getStringByKey(DataKey.Source, "");
            item = param1.getStringByKey(DataKey.Item, "");
            params = param1.getStringByKey(DataKey.Params, "");
            
            if (source != "" && item == "")
			{
                return;
            }
			
            if (subscribeFlag)
			{
                dispatchEvent(new SourceEvent(SourceEvent.SUBSCRIBE, source, item, params));
            }
            else{
                dispatchEvent(new SourceEvent(SourceEvent.UNSUBSCRIBE, source, item, params));
            }
            return;
        }// end function

        public function unmount() : void 
		{
            var msg:Message = null;
            if (!requestId){
                return;
            }
			msg = new Message();
			msg.type = MessageType.Dismount;
			msg.addString(DataKey.Source, source);
            _connection.send(msg);
            _connection.closeRequest(requestId);
            requestId = 0;
            _mountResult = DataError.None;
            return;
        }// end function

    }
}
