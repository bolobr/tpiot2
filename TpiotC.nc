// $Id: BlinkC.nc,v 1.6 2010-06-29 22:07:16 scipio Exp $

/*									tab:4
 * Copyright (c) 2000-2005 The Regents of the University  of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the University of California nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Copyright (c) 2002-2003 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA,
 * 94704.  Attention:  Intel License Inquiry.
 */

#include "Tpiot.h"
/**
 * Implementation for Blink application.  Toggle the red LED when a
 * Timer fires.
 **/

#include "Timer.h"

module TpiotC @safe()
{
  uses interface Leds;
  uses interface Boot;
  uses interface Receive;
  uses interface AMSend;
  uses interface SplitControl as AMControl;
  uses interface Timer<TMilli> as MilliTimer;
  uses interface Packet;

}
implementation
{
  message_t packet;
  bool locked;
  int parent = -1;
  event void Boot.booted()
  {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    dbg("Boot", "Begining Radio Module\n");
    if (err == SUCCESS) {
      call Leds.led0Off();
      call Leds.led1Off();
      call Leds.led2Off();
      call MilliTimer.startPeriodic(250);

    }
    else {
      call AMControl.start();
    }
  }

  event void MilliTimer.fired() {
    dbg("Timer", "Beggining node checking\n");
    if(locked){
      return;
    }
    else{
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {
	      dbg("Timer", "Message Sent.\n");
        locked = TRUE;
      }
    }
  }

  event message_t* Receive.receive(message_t* bufPtr,
  			   void* payload, uint8_t len) {
    call Leds.led0On();
    //call Leds.led1On();
    call Leds.led2On();
    //dbg("Radio", "Receiving message\n");
    return bufPtr;
    //if (parent > 0) {return bufPtr;}
    //else {
    //  dbg("Radio", "Message received");
    //}
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

  event void AMControl.stopDone(error_t err){
    dbg("Radio", "RadioCountToLedsC: packet sent.\n");
  }
}
