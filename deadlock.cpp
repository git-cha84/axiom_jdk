#include <thread>
#include <mutex>
#include <chrono>

std::mutex mutex;

std::mutex mutexDeadLock1;
std::mutex mutexDeadLock2;

void threadFunctionDeadLock1() {
    std::lock_guard<std::mutex> lock1(mutexDeadLock2);
    std::this_thread::sleep_for(std::chrono::seconds(1));
    std::lock_guard<std::mutex> lock2(mutexDeadLock1);
}

void threadFunctionDeadLock2() {
    std::lock_guard<std::mutex> lock2(mutexDeadLock1);
    std::this_thread::sleep_for(std::chrono::seconds(1));
    std::lock_guard<std::mutex> lock1(mutexDeadLock2);
}


void threadSleepFunction() {
    for (int i = 0; i < 50; ++i) {
        std::lock_guard<std::mutex> lock(mutex);
        std::this_thread::sleep_for(std::chrono::milliseconds(127));
    }
}

int main(int argc, char* argv[]) {

 if (argc > 1 && std::string(argv[1]) == "--d") {
  std::thread tDeadLock1(threadFunctionDeadLock1);
  std::thread tDeadLock2(threadFunctionDeadLock2);
  tDeadLock1.join();
  tDeadLock2.join();
 } else{


 std::thread t1(threadSleepFunction);
 std::thread t2(threadSleepFunction);

 t1.join();
 t2.join();
 }

 return 0;
}

