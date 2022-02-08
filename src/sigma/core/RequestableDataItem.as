package sigma.core
{
    import mx.logging.*;

    public class RequestableDataItem extends DataItemWithStatus 
	{
        public var tag:Object;
        public var conflation:int = 250;
		public var type:int;
        private var _id:int = 0;
        public var format:int = 0;
        public var filter:String = "";
        private static var _log:ILogger = Log.getLogger("cog.data3.item");

        public function RequestableDataItem() 
		{
            _id = 0;
            filter = "";
            conflation = 250;
            format = DataFormat.None;
            return;
        }// end function

        public function unsubscribe() : void 
		{
            if (_id == 0)
			{
                return;
            }
            _log.debug("unsubscribing: " + source + " " + item + " filter:" + filter);
            connection.closeRequest(_id);
            _id = 0;
            _readOnly = false;
            setStatus(DataState.Closed, DataError.None, "");
            return;
        }// end function

        public function subscribe() : void 
		{
            var msg:Message = null;
            unsubscribe();
            trace("subscribing to: \'" + source + "\' \'" + item + "\' filter:\'" + filter + "\'");
            _readOnly = true;
            setStatus(DataState.Pending, DataError.None, "");
			msg = new Message();
			msg.type = MessageType.Subscribe ;
			msg.addString(DataKey.Source, source) ;
			msg.addString(DataKey.Item, item);
			msg.addInt(DataKey.Format, format);
            if (conflation > 0)
			{
				msg.addInt(DataKey.Conflation, conflation);
            }
            if (filter != "" && filter != null )
			{
				msg.addString(DataKey.Filter, filter);
            }
            _id = connection.openRequest(msg, this);
            return;
        }// end function

    }
}
