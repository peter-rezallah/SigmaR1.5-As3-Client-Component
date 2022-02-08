package sigma.core
{
	
    public class DataItemPublisher extends DataItem 
	{
        protected var message:Message = null;
        protected var format:int = 0;

        public function DataItemPublisher() {
            message = null;
            format = DataFormat.None;
            reset();
            return;
        }// end function

        public function send(param1:Boolean) : Boolean 
		{
            if (connection != null && source != "" && item == "" )
			{
				return false;
            }
           
            message.type = param1 ? (MessageType.Image) : (MessageType.Update);
            message.addString(DataKey.Source, source);
            message.addString(DataKey.Item, item);
            if (parameters.length > 0)
			{
                message.addString(DataKey.Params, parameters);
            }
            message.addInt(DataKey.Format, format);
            if (!connection.send(message))
			{
                return false;
            }
            reset();
            return true;
        }// end function

        public function reset() : void {
            message = new Message();
            return;
        }// end function

    }
}
