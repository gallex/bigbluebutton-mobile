/*
 * BigBlueButton - http://www.bigbluebutton.org
 * 
 * Copyright (c) 2008-2009 by respective authors (see below). All rights reserved.
 * 
 * BigBlueButton is free software; you can redistribute it and/or modify it under the 
 * terms of the GNU Lesser General Public License as published by the Free Software 
 * Foundation; either version 3 of the License, or (at your option) any later 
 * version. 
 * 
 * BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY 
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
 * PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License along 
 * with BigBlueButton; if not, If not, see <http://www.gnu.org/licenses/>.
 *
 * $Id: $
 */
package org.bigbluebutton.android.services
{
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
		        	
	public class JoinService
	{  
		public static const DEFAULT_JOIN:String = "conf/join-mock.xml";
		
		private var request:URLRequest = new URLRequest();
		private var vars:URLVariables = new URLVariables();
		
		private var urlLoader:URLLoader;
		private var _resultListener:Function;
		
		public function JoinService()
		{
			urlLoader = new URLLoader();
		}
		
		public function load(url:String) : void
		{			            
            request = new URLRequest(url);
            request.method = URLRequestMethod.GET;		
            
			urlLoader.addEventListener(Event.COMPLETE, handleComplete);	
            urlLoader.load(request);			
			trace("Loading " + url);
		}

		public function addJoinResultListener(listener:Function):void {
			_resultListener = listener;
		}
		
		private function handleComplete(e:Event):void {			
			var xml:XML = new XML(e.target.data)

			var returncode:String = xml.returncode;
			if (returncode == 'FAILED') {
				_resultListener(false, {message:xml.message});
			} else if (returncode == 'SUCCESS') {
				var user:Object = {username:xml.fullname, conference:xml.conference, conferenceName:xml.confname,
										meetingID:xml.meetingID, externUserID:xml.externUserID,
										role:xml.role, room:xml.room, authToken:xml.room, record:xml.record, 
										webvoiceconf:xml.webvoiceconf,
										voicebridge:xml.voicebridge, mode:xml.mode, welcome:xml.welcome};
				
				if (_resultListener != null) _resultListener(true, user);
			}
				
		}
		
		public function get loader():URLLoader{
			return this.urlLoader;
		}
	}
}