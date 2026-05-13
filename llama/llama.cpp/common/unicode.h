#pragma once
#include <cstdint>
#include <string>
#include <string_view>
#include <vector>

struct utf8_parse_result {
    uint32_t codepoint;
    size_t bytes_consumed;
    enum status { SUCCESS, INCOMPLETE, INVALID } status;

    utf8_parse_result(enum status s, uint32_t cp = 0, size_t bytes = 0)
        : codepoint(cp), bytes_consumed(bytes), status(s) {}
};

inline utf8_parse_result common_parse_utf8_codepoint(std::string_view input, size_t offset) {
    // Simplified stub - just return SUCCESS for ASCII
    if (offset < input.size()) {
        unsigned char c = input[offset];
        if (c < 0x80) {
            return utf8_parse_result(utf8_parse_result::SUCCESS, c, 1);
        }
    }
    return utf8_parse_result(utf8_parse_result::INVALID);
}

inline std::string common_unicode_cpts_to_utf8(const std::vector<uint32_t> & cps) {
    std::string result;
    for (auto cp : cps) {
        if (cp < 0x80) result += (char)cp;
    }
    return result;
}

inline std::string common_unicode_cpt_to_utf8(uint32_t cpt) {
    if (cpt < 0x80) return std::string(1, (char)cpt);
    return "";
}

inline bool common_utf8_is_complete(const std::string & s) {
    return true;
}
