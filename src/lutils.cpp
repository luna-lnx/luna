using namespace std;

#include <string>
#include <deque>

std::deque<std::string> split(std::string in, std::string del){
    deque<string> out;
    size_t pos = 0;
    while((pos = in.find(del)) != string::npos){
        out.push_front(in.substr(0, pos));
        in.erase(0, pos + del.length());
    }
    out.push_front(in);
    return out;
}