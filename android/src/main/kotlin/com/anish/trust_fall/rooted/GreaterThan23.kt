package com.anish.trust_fall.rooted

import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader

class GreaterThan23 : CheckApiVersion {
    override fun checkRooted(): Boolean {
        return checkRootMethod1() || checkRootMethod2()
    }

    private fun checkRootMethod1(): Boolean {
        for (path in SU_PATHS) {
            if (File(path).exists()) return true
        }
        return false
    }

    private fun checkRootMethod2(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("/system/xbin/which", "su"))
            BufferedReader(InputStreamReader(process.inputStream)).use {
                it.readLine() != null
            }
        } catch (t: Throwable) {
            false
        }
    }
}