#! /usr/bin/env python

import gdb

class Thread():
    def __init__(self):
        self.waitMutexOwner = None
        self.id = None
        

class FoundBlockedThreads(gdb.Command):

    def __init__(self):
        super (FoundBlockedThreads, self).__init__("found_blocked_threads", gdb.COMMAND_SUPPORT,gdb.COMPLETE_NONE,True)
        self.mutexString = "pthread_mutex_lock"
        self.printMutexOwner = "print mutex.__data.__owner"
        self.threads = {}
       

    def initThreadsDescript(self):
        threadsProcess = gdb.selected_inferior().threads()

        for thread in threadsProcess:
            curThr = Thread()
            curThr.id = thread.ptid[1] 
            thread.switch()
            frame = gdb.selected_frame()
            while frame:
                frame.select()
                name = frame.name()
                if name is None:
                    name = "??"
                if self.mutexString in name:
                    curThr.waitMutexOwner = int(gdb.execute(self.printMutexOwner, to_string=True).split()[2])
                frame = frame.older()
            self.threads[curThr.id] = curThr
        return
            

    def testDeadLocks(self):
        for (idx,thread) in self.threads.items():
            if thread.waitMutexOwner:
                if thread.waitMutexOwner in self.threads and self.threads[thread.waitMutexOwner].waitMutexOwner == thread.id:
                    print ("DETECTED_DEADLOCK")
                    break
        return

            
    def invoke(self, arg, from_tty):
        self.initThreadsDescript()
        self.testDeadLocks()


         

FoundBlockedThreads()
