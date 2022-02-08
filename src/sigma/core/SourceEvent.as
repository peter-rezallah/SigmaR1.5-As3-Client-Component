package sigma.core
{
    import flash.events.*;

    public class SourceEvent extends Event {
        public var parameters:String = "";
        public var item:String = "";
        public var source:String = "";
        public static const UNSUBSCRIBE:String = "SourceEvent_UNSUBSCRIBE";
        public static const SUBSCRIBE:String = "SourceEvent_SUBSCRIBE";

        public function SourceEvent(param1:String, param2:String, param3:String, param4:String) : void {
            source = "";
            item = "";
            parameters = "";
            super(param1);
            this.source = param2;
            this.item = param3;
            this.parameters = param4;
            return;
        }// end function

        override public function clone() : Event {
            return new SourceEvent(type, source, item, parameters);
        }// end function

    }
}
