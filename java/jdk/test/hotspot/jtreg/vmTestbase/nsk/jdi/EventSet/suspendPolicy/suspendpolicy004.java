/*
 * Copyright (c) 2001, 2024, Oracle and/or its affiliates. All rights reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * You should have received a copy of the GNU General Public License version
 * 2 along with this work; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
 * or visit www.oracle.com if you need additional information or have any
 * questions.
 */

package nsk.jdi.EventSet.suspendPolicy;

import nsk.share.*;
import nsk.share.jpda.*;
import nsk.share.jdi.*;

import com.sun.jdi.*;
import com.sun.jdi.event.*;
import com.sun.jdi.request.*;

import java.util.*;
import java.io.*;

/**
 * The test for the implementation of an object of the type     <BR>
 * EventSet.                                                    <BR>
 *                                                              <BR>
 * The test checks that results of the method                   <BR>
 * <code>com.sun.jdi.EventSet.suspendPolicy()</code>            <BR>
 * complies with its spec.                                      <BR>
 * <BR>
 * The test checks that for a BreakpointEvent set,              <BR>
 * the method returns a value corresponding to one              <BR>
 * which suspends the most threads.                             <BR>
 * The cases to check include event sets containing             <BR>
 * one to three threads with all possible combinations:         <BR>
 *    NONE, THREAD, ALL, NONE+THREAD, NONE+ALL,                 <BR>
 *    THREAD+ALL, NONE+THREAD+ALL                               <BR>
 * <BR>
 * The test has three phases and works as follows.              <BR>
 * <BR>
 * In first phase,                                                      <BR>
 * upon launching debuggee's VM which will be suspended,                <BR>
 * a debugger waits for the VMStartEvent within a predefined            <BR>
 * time interval. If no the VMStartEvent received, the test is FAILED.  <BR>
 * Upon getting the VMStartEvent, it makes the request for debuggee's   <BR>
 * ClassPrepareEvent with SUSPEND_EVENT_THREAD, resumes the VM,         <BR>
 * and waits for the event within the predefined time interval.         <BR>
 * If no the ClassPrepareEvent received, the test is FAILED.            <BR>
 * Upon getting the ClassPrepareEvent,                                  <BR>
 * the debugger sets up the breakpoint with SUSPEND_EVENT_THREAD        <BR>
 * within debuggee's special methodForCommunication().                  <BR>
 * <BR>
 * In second phase to check the above,                                  <BR>
 * the debugger and the debuggee perform the following loop.            <BR>
 * - The debugger sets up a BreakpointRequest,                          <BR>
 *   resumes the debuggee, and waits for the BreakpointEvent.           <BR>
 * - The debuggee invokes the special method in which control passes    <BR>
 *   through a predefined line to be resulting in the event.            <BR>
 * - Upon getting new event, the debugger                               <BR>
 *   performs the check corresponding to the event.                     <BR>
 * <BR>
 * Note. To inform each other of needed actions, the debugger and       <BR>
 *       and the debuggee use debuggee's variable "instruction".        <BR>
 * In third phase, at the end,                                          <BR>
 * the debuggee changes the value of the "instruction"                  <BR>
 * to inform the debugger of checks finished, and both end.             <BR>
 * <BR>
 */

public class suspendpolicy004 extends JDIBase {

    public static void main (String argv[]) {

        int result = run(argv, System.out);

        if (result != 0) {
            throw new RuntimeException("TEST FAILED with result " + result);
        }
    }

    public static int run (String argv[], PrintStream out) {

        int exitCode = new suspendpolicy004().runThis(argv, out);

        if (exitCode != PASSED) {
            System.out.println("TEST FAILED");
        }
        return exitCode;
    }

    //  ************************************************    test parameters

    private String debuggeeName =
        "nsk.jdi.EventSet.suspendPolicy.suspendpolicy004a";

    private String testedClassName =
        "nsk.jdi.EventSet.suspendPolicy.suspendpolicy004aTestClass";

    //====================================================== test program

    private int runThis (String argv[], PrintStream out) {

        argsHandler     = new ArgumentHandler(argv);
        logHandler      = new Log(out, argsHandler);
        Binder binder   = new Binder(argsHandler, logHandler);

        waitTime        = argsHandler.getWaitTime() * 60000;

        try {
            log2("launching a debuggee :");
            log2("       " + debuggeeName);
            if (argsHandler.verbose()) {
                debuggee = binder.bindToDebugee(debuggeeName + " -vbs");
            } else {
                debuggee = binder.bindToDebugee(debuggeeName);
            }
            if (debuggee == null) {
                log3("ERROR: no debuggee launched");
                return FAILED;
            }
            log2("debuggee launched");
        } catch ( Exception e ) {
            log3("ERROR: Exception : " + e);
            log2("       test cancelled");
            return FAILED;
        }

        debuggee.redirectOutput(logHandler);

        vm = debuggee.VM();

        eventQueue = vm.eventQueue();
        if (eventQueue == null) {
            log3("ERROR: eventQueue == null : TEST ABORTED");
            vm.exit(PASS_BASE);
            return FAILED;
        }

        log2("invocation of the method runTest()");
        switch (runTest()) {

            case 0 :  log2("test phase has finished normally");
                      log2("   waiting for the debuggee to finish ...");
                      debuggee.waitFor();

                      log2("......getting the debuggee's exit status");
                      int status = debuggee.getStatus();
                      if (status != PASS_BASE) {
                          log3("ERROR: debuggee returned UNEXPECTED exit status: " +
                              status + " != PASS_BASE");
                          testExitCode = FAILED;
                      } else {
                          log2("......debuggee returned expected exit status: " +
                              status + " == PASS_BASE");
                      }
                      break;

            default : log3("ERROR: runTest() returned unexpected value");

            case 1 :  log3("test phase has not finished normally: debuggee is still alive");
                      log2("......forcing: vm.exit();");
                      testExitCode = FAILED;
                      try {
                          vm.exit(PASS_BASE);
                      } catch ( Exception e ) {
                          log3("ERROR: Exception : e");
                      }
                      break;

            case 2 :  log3("test cancelled due to VMDisconnectedException");
                      log2("......trying: vm.process().destroy();");
                      testExitCode = FAILED;
                      try {
                          Process vmProcess = vm.process();
                          if (vmProcess != null) {
                              vmProcess.destroy();
                          }
                      } catch ( Exception e ) {
                          log3("ERROR: Exception : e");
                      }
                      break;
            }

        return testExitCode;
    }


   /*
    * Return value: 0 - normal end of the test
    *               1 - ubnormal end of the test
    *               2 - VMDisconnectedException while test phase
    */

    private int runTest() {

        try {
            testRun();

            log2("waiting for VMDeathEvent");
            getEventSet();
            if ( !(eventIterator.nextEvent() instanceof VMDeathEvent) ) {
                log3("ERROR: last event is not the VMDeathEvent");
                return 1;
            }

            log2("waiting for VMDisconnectEvent");
            getEventSet();
            if ( !(eventIterator.nextEvent() instanceof VMDisconnectEvent) ) {
                log3("ERROR: last event is not the VMDisconnectEvent");
                return 1;
            }

            return 0;

        } catch ( VMDisconnectedException e ) {
            log3("ERROR: VMDisconnectedException : " + e);
            return 2;
        } catch ( Exception e ) {
            log3("ERROR: Exception : " + e);
            return 1;
        }

    }

    private void testRun()
                 throws JDITestRuntimeException, Exception {

        eventRManager = vm.eventRequestManager();

        log2("......getting ClassPrepareEvent for debuggee's class");
        ClassPrepareRequest cpRequest = eventRManager.createClassPrepareRequest();
        cpRequest.setSuspendPolicy( EventRequest.SUSPEND_EVENT_THREAD);
        cpRequest.addClassFilter(debuggeeName);
        cpRequest.enable();
        vm.resume();
        getEventSet();
        cpRequest.disable();

        ClassPrepareEvent event = (ClassPrepareEvent) eventIterator.next();
        debuggeeClass = event.referenceType();

        if (!debuggeeClass.name().equals(debuggeeName))
           throw new JDITestRuntimeException("** Unexpected ClassName for ClassPrepareEvent **");
        log2("      received: ClassPrepareEvent for debuggeeClass");

        log2("......setting up ClassPrepareEvent for breakpointForCommunication");

        String            bPointMethod = "methodForCommunication";
        String            lineForComm  = "lineForComm";
        BreakpointRequest bpRequest;
        ThreadReference   mainThread = debuggee.threadByNameOrThrow("main");
        bpRequest = settingBreakpoint(mainThread,
                                      debuggeeClass,
                                      bPointMethod, lineForComm, "zero");
        bpRequest.enable();

        vm.resume();

    //------------------------------------------------------  testing section

        log1("     TESTING BEGINS");

        EventRequest eventRequest1 = null;
        EventRequest eventRequest2 = null;
        EventRequest eventRequest3 = null;

        final int SUSPEND_POLICY = EventRequest.SUSPEND_NONE;
        final int SUSPEND_NONE   = EventRequest.SUSPEND_NONE;
        final int SUSPEND_THREAD = EventRequest.SUSPEND_EVENT_THREAD;
        final int SUSPEND_ALL    = EventRequest.SUSPEND_ALL;

        int policyExpected[] = {    SUSPEND_NONE,
                                    SUSPEND_THREAD,
                                    SUSPEND_ALL,
                                    SUSPEND_THREAD,
                                    SUSPEND_ALL,
                                    SUSPEND_ALL,
                                    SUSPEND_ALL      };
        int policy = 0;


        ReferenceType testClassReference = null;

        String methodName = "method";
        String bpLineName = "breakpointLine";


        for (int i = 0; ; i++) {


            breakpointForCommunication();

            int instruction = ((IntegerValue)
                               (debuggeeClass.getValue(debuggeeClass.fieldByName("instruction")))).value();
            if (instruction == 0) {
                vm.resume();
                break;
            }


            log1(":::::: case: # " + i);

            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ variable part

            switch (i) {

              case 0:
                      testClassReference =
                           (ReferenceType) vm.classesByName(testedClassName).get(0);

                      eventRequest1 = settingBreakpointRequest (mainThread,
                                             testClassReference, methodName, bpLineName,
                                             SUSPEND_NONE, "BreakpointRequest1");
                      eventRequest1.enable();
                      break;

              case 1:
                      eventRequest2 = settingBreakpointRequest (mainThread,
                                             testClassReference, methodName, bpLineName,
                                             SUSPEND_THREAD, "BreakpointRequest2");
                      eventRequest2.enable();
                      break;

              case 2:
                      eventRequest3 = settingBreakpointRequest (mainThread,
                                             testClassReference, methodName, bpLineName,
                                             SUSPEND_ALL, "BreakpointRequest3");
                      eventRequest3.enable();
                      break;

              case 3:
                      eventRequest1 = settingBreakpointRequest (mainThread,
                                             testClassReference, methodName, bpLineName,
                                             SUSPEND_NONE, "BreakpointRequest4");
                      eventRequest1.enable();
                      eventRequest2 = settingBreakpointRequest (mainThread,
                                             testClassReference, methodName, bpLineName,
                                             SUSPEND_THREAD, "BreakpointRequest5");
                      eventRequest2.enable();
                      break;

              case 4:
                      eventRequest1 = settingBreakpointRequest (mainThread,
                                             testClassReference, methodName, bpLineName,
                                             SUSPEND_NONE, "BreakpointRequest6");
                      eventRequest1.enable();
                      eventRequest3 = settingBreakpointRequest (mainThread,
                                             testClassReference, methodName, bpLineName,
                                             SUSPEND_ALL, "BreakpointRequest7");
                      eventRequest3.enable();
                      break;

              case 5:
                      eventRequest2 = settingBreakpointRequest (mainThread,
                                             testClassReference, methodName, bpLineName,
                                             SUSPEND_THREAD, "BreakpointRequest8");
                      eventRequest2.enable();
                      eventRequest3 = settingBreakpointRequest (mainThread,
                                             testClassReference, methodName, bpLineName,
                                             SUSPEND_ALL, "BreakpointRequest9");
                      eventRequest3.enable();
                      break;

              case 6:
                      eventRequest1 = settingBreakpointRequest (mainThread,
                                             testClassReference, methodName, bpLineName,
                                             SUSPEND_NONE, "BreakpointRequest10");
                      eventRequest1.enable();
                      eventRequest2 = settingBreakpointRequest (mainThread,
                                             testClassReference, methodName, bpLineName,
                                             SUSPEND_THREAD, "BreakpointRequest11");
                      eventRequest2.enable();
                      eventRequest3 = settingBreakpointRequest (mainThread,
                                             testClassReference, methodName, bpLineName,
                                             SUSPEND_ALL, "BreakpointRequest12");
                      eventRequest3.enable();
                      break;


              default:
                      throw new JDITestRuntimeException("** default case 2 **");
            }

            log2("......waiting for new BreakpointEvent : " + i);
            mainThread.resume();
            getEventSet();

            Event newEvent = eventIterator.nextEvent();
            log2("       got new Event with propety 'number' == " + newEvent.request().getProperty("number"));
            if ( !( newEvent instanceof BreakpointEvent)) {
                 log3("ERROR: new event is not BreakpointEvent");
                 testExitCode = FAILED;
            } else {
                log2("       Event is instanceof BreakpointEvent");
                policy = eventSet.suspendPolicy();
                if (policy != policyExpected[i]) {
                    log3("ERROR: eventSet.suspendPolicy() != policyExpected");
                    log3("       eventSet.suspendPolicy() == " + policy);
                    log3("       policyExpected           == " + policyExpected[i]);
                    testExitCode = FAILED;
                }
            }

            switch (i) {
              case 0: eventRequest1.disable();                          break;
              case 1: eventRequest2.disable();                          break;
              case 2: eventRequest3.disable();                          break;
              case 3: eventRequest1.disable(); eventRequest2.disable(); break;
              case 4: eventRequest1.disable(); eventRequest3.disable(); break;
              case 5: eventRequest2.disable(); eventRequest3.disable(); break;
              case 6: eventRequest1.disable(); eventRequest2.disable();
                      eventRequest3.disable();                          break;
           }

            switch (policy) {
              case SUSPEND_NONE   :                      break;
              case SUSPEND_THREAD : mainThread.resume(); break;
              case SUSPEND_ALL    : vm.resume();         break;
              default: throw new JDITestRuntimeException("** default case 3 **");
            }

            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        }
        log1("    TESTING ENDS");
        return;
    }

    // ============================== test's additional methods

    private BreakpointRequest settingBreakpointRequest ( ThreadReference thread,
                                                         ReferenceType   testedClass,
                                                         String          methodName,
                                                         String          bpLine,
                                                         int             suspendPolicy,
                                                         String          property        )
            throws JDITestRuntimeException {
        try {
            log2("......setting up a breakpoint:");
            log2("       thread: " + thread + "; class: " + testedClass + "; method: " + methodName + "; line: " + bpLine);

            int n = ( (IntegerValue) testedClass.getValue(testedClass.fieldByName(bpLine) ) ).value();
            Location loc = (Location) ((Method) testedClass.methodsByName(methodName).get(0)).allLineLocations().get(n);

            BreakpointRequest
            bpr = eventRManager.createBreakpointRequest(loc);
            bpr.putProperty("number", property);
            bpr.addThreadFilter(thread);
            bpr.setSuspendPolicy(suspendPolicy);

            log2("      a breakpoint has been set up");
            return bpr;
        } catch ( Exception e ) {
            log3("ERROR: ATTENTION: Exception within settingBreakpointRequest() : " + e);
            log3("       BreakpointRequest HAS NOT BEEN SET UP");
            throw new JDITestRuntimeException("** FAILURE to set up BreakpointRequest **");
        }
    }

}