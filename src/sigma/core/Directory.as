package sigma.core
{
    import mx.logging.*;
    

    public class Directory extends Table 
	{
        private var _Sources:Array;
        public static const ITEM:String = "#dir";
        private static var _log:ILogger = Log.getLogger("cog.data3.directory");
        public static const SOURCE:String = "#root";

        public function Directory() 
		{
            source = SOURCE;
            item = ITEM;
            super.addEventListener(DataItemUpdateEvent.END, OnEndUpdate);
            return;
        }// end function

        public function GetSources() : Array {
            return _Sources;
        }// end function

        private function OnEndUpdate(event:DataItemUpdateEvent) : void {
            var _loc_2:int = 0;
            _Sources = new Array();
            _loc_2 = 0;
            while (_loc_2 < getRowCount())
			{
                
                _log.debug("Received row " + getRowName(_loc_2));
                _Sources.push(getRowName(_loc_2));
                _loc_2 = _loc_2 + 1;
            }
            return;
        }// end function

    }
}
