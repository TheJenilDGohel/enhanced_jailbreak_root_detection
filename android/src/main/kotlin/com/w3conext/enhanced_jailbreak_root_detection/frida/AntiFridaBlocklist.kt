package com.w3conext.enhanced_jailbreak_root_detection.frida

import android.util.Log

object AntiFridaBlocklist {

    private const val TAG = "FridaModuleBlocklist"

    private val TARGETS = listOf(
        "frida-agent",
        "frida-gadget"
    )

    fun check(mapsFileContent: String?): Boolean {
        if (mapsFileContent == null) {
            Log.d(TAG, "maps got null")
            return false
        }

        for (target in TARGETS) {
            if (target in mapsFileContent)
                return true
        }
        return false
    }

    fun checkContain(result: String): Boolean {
        for (module in TARGETS) {
            if (result.contains(module)) {
                return true
            }
        }
        return false
    }
}