package sigma.core
{
    import flash.events.*;

    public class SourceMountEvent extends Event {
        public var result:DataError;
        public static const RESULT:String = "SourceMountEvent_RESULT";

        public function SourceMountEvent(param1:String, param2:DataError) : void {
            result = DataError.None;
            super(param1);
            this.result = param2;
            return;
        }// end function

        override public function clone() : Event {
            return new SourceMountEvent(type, result);
        }// end function

    }
}
