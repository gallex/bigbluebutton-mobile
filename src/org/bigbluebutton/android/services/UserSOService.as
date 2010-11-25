package org.bigbluebutton.android.services
{
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.net.SharedObject;
	
	import org.bigbluebutton.android.model.ConferenceParameters;
	import org.bigbluebutton.android.model.User;
	import org.bigbluebutton.android.model.UserDirectory;

	public class UserSOService
	{
		public static const CONNECT_SUCCESS:String = "NetConnection.Connect.Success";
		public static const CONNECT_FAILED:String = "NetConnection.Connect.Failed";
		public static const CONNECT_CLOSED:String = "NetConnection.Connect.Closed";
		public static const INVALID_APP:String = "NetConnection.Connect.InvalidApp";
		public static const APP_SHUTDOWN:String = "NetConnection.Connect.AppShutDown";
		public static const CONNECT_REJECTED:String = "NetConnection.Connect.Rejected";
		
		private static const SO_NAME : String = "participantsSO";
		
		private var nc:NetConnection;
		private var params:ConferenceParameters;
		private var uri:String;
		
		private var userid:Number;
		private var participantsSO:SharedObject;
		private var userDir:UserDirectory;
		
		public function UserSOService(appUri:String, _conferenceParameters:ConferenceParameters)
		{
			params = _conferenceParameters;
			uri = appUri + "/" + _conferenceParameters.room;
			trace(uri);
			
			nc = new NetConnection();
			nc.client = this;
			nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			nc.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			nc.connect(uri, _conferenceParameters.username, _conferenceParameters.role, _conferenceParameters.conference, 
				_conferenceParameters.mode, _conferenceParameters.room, _conferenceParameters.voicebridge, 
				false, _conferenceParameters.externUserID);	
		}
		
		private function onAsyncError(e:AsyncErrorEvent):void{
			trace("ERROR: ASYNC ERROR");
		}
		
		private function ioError(e:IOErrorEvent):void{
			trace("ERROR: IO Error");
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void{
			trace("ERROR: Security Error");
		}
		
		private function onNetStatus(e:NetStatusEvent):void{
			var status:String = e.info.code;
			trace(status);
			
			switch ( status ) 
			{
				case CONNECT_SUCCESS :
					trace("calling getMyUserId");
					nc.call(
						"getMyUserId",// Remote function name
						new Responder(
							// result - On successful result
							function(result:Object):void { 
								connectionSuccess(result);
							},	
							// status - On error occurred
							function(status:Object):void { 
								trace("error " + status.toString());
							}
						)//new Responder
					); //_netConnection.call
					
					break;
				
				case CONNECT_FAILED :					
					trace("ERROR: Connection Failed");								
					break;
				
				case CONNECT_CLOSED :	
					trace("DEBUG: Connection Closed");						
					break;
				
				case INVALID_APP :	
					trace("ERROR: The red5 app could not be found");
					break;
				
				case APP_SHUTDOWN :
					trace("ERROR: The red5 app has shut down");
					break;
				
				case CONNECT_REJECTED :
					trace("DEBUG: The connection to red5 has been rejected");
					break;
				
				default :
					trace("DEBUG: The connection has been lost for an unknown reason");
					break;
			}
		}
		
		private function connectionSuccess(result:Object):void{
			trace("Connection to red5 successfully established");
			
			var useridString:String = result as String;
			this.userid = parseInt(useridString);
			trace("My user id: " + this.userid);
			
			join();
		}
		
		public function join() : void
		{
			participantsSO = SharedObject.getRemote(SO_NAME, uri, false);
			participantsSO.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			participantsSO.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			participantsSO.client = this;
			participantsSO.connect(nc);
			
			queryForParticipants();		
			
		}
		
		private function queryForParticipants():void {
			userDir = new UserDirectory();
			
			nc.call(
				"participants.getParticipants",// Remote function name
				new Responder(
					// participants - On successful result
					function(result:Object):void { 
						trace("Successfully queried participants: " + result.count); 
						if (result.count > 0) {
							for(var p:Object in result.participants) 
							{
								participantJoined(result.participants[p]);
							}		
						}	
						
					},	
					// status - On error occurred
					function(status:Object):void { 
						for (var x:Object in status) { 
							trace(x);
						} 
					}
				)//new Responder
			); //_netConnection.call
		}
		
		public function participantJoined(joinedUser:Object):void {
			var user:User = new User();
			user.userid = Number(joinedUser.userid);
			user.name = joinedUser.name;
			user.role = joinedUser.role;
						
			trace("Joined as [" + user.userid + "," + user.name + "," + user.role + "]");
			userDir.addUser(user);
			
			//participantStatusChange(user.userid, "hasStream", joinedUser.status.hasStream);
			//participantStatusChange(user.userid, "streamName", joinedUser.status.streamName);
			//participantStatusChange(user.userid, "presenter", joinedUser.status.presenter);
			//participantStatusChange(user.userid, "raiseHand", joinedUser.status.raiseHand);			
		}
	
	}
}