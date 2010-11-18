package org.bigbluebutton.mobile.model
{
	public class UserDirectory
	{
		private var users:Array;
		
		public function UserDirectory()
		{
			users = new Array();
		}
		
		public function addUser(user:User):void{
			users[users.length] = user;
		}
		
		public function getUser(userid:Number):void{
			
		}
	}
}