package org.bigbluebutton.android.model
{
	public class Conference
	{
		public var me:User;
		public var users:Array;
		
		public function Conference(){
			me = new User();
			users = new Array();
		}
	}
}