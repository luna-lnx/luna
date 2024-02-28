#include "liblpkg.hpp"
#include "jerryscript-core.h"
#include "jerryscript-types.h"
#include "logger.hpp"
#include <fstream>
#include <sstream>
#include <string.h>

namespace liblpkg
{
Lpkg parse_lpkg(std::string str)
{
	const unsigned char *script = reinterpret_cast<const unsigned char *>(str.c_str());

	const jerry_length_t script_size = str.size();
	jerry_init(JERRY_INIT_EMPTY);

	jerry_value_t eval_ret = jerry_eval(script, script_size, JERRY_PARSE_NO_OPTS);

	jerry_value_t global_object = jerry_current_realm();
	jerry_value_t test = jerry_object_get(global_object, jerry_string_sz("name"));
	jerry_size_t bufsize = jerry_string_size(test, JERRY_ENCODING_UTF8);
	jerry_char_t buffer[bufsize];
	jerry_string_to_buffer(test, JERRY_ENCODING_UTF8, buffer, bufsize);
	buffer[bufsize] = '\0';
	log(LogLevel::DEBUG, "{}", buffer);
	jerry_value_free(eval_ret);
	jerry_value_free(test);
	jerry_value_free(global_object);
	jerry_cleanup();
}
Lpkg parse_lpkg_from_file(std::string path)
{
	std::ifstream file(path);
	std::stringstream stream;
	stream << file.rdbuf();
	parse_lpkg(stream.str());
}
} // namespace liblpkg