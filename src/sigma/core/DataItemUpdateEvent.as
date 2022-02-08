package sigma.core
{
    import flash.events.*;

    public class DataItemUpdateEvent extends Event {
        public var image:Boolean;
        public static const BEGIN:String = "DataItemUpdateEvent_BEGIN";
        public static const END:String = "DataItemUpdateEvent_END";

        public function DataItemUpdateEvent(param1:String, param2:Boolean) {
            super(param1);
            this.image = param2;
            return;
        }// end function

        override public function clone() : Event {
            return new DataItemUpdateEvent(type, image);
        }// end function

    }
}
