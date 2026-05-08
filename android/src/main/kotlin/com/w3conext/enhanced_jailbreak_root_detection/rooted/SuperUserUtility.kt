package com.w3conext.enhanced_jailbreak_root_detection.rooted

import android.util.Log
import java.io.BufferedReader
import java.io.DataOutputStream
import java.io.InputStreamReader

object SuperUserUtility {

    private const val TAG: String = "SuperUserUtility"

    private var rooted = false

    fun tryRoot(pkgCodePath: String): Boolean {
        // try exec su and refresh `rooted`
        var process: Process? = null
        var dos: DataOutputStream? = null
        try {
            process = Runtime.getRuntime().exec("su")
            dos = DataOutputStream(process.outputStream)
            dos.writeBytes("chmod 777 ${pkgCodePath}\n")
            dos.writeBytes("exit\n")
            dos.flush()
            rooted = process.waitFor() == 0
        } catch (e: Exception) {
            rooted = false
        } finally {
            dos?.close()
            process?.destroy()
        }
        return rooted
    }

    fun execRootCmd(cmd: String): String {
        if (!rooted) return ""

        var out = ""
        try {
            val process = Runtime.getRuntime().exec("su")
            val stdin = DataOutputStream(process.outputStream)
            val stdout = process.inputStream
            val stderr = process.errorStream

            Log.i(TAG, "execRootCmd: $cmd")
            stdin.writeBytes(cmd + "\n")
            stdin.flush()
            stdin.writeBytes("exit\n")
            stdin.flush()
            stdin.close()

            var line: String?

            BufferedReader(InputStreamReader(stdout)).use { br ->
                while ((br.readLine().also { line = it }) != null) {
                    out += line
                }
            }
            BufferedReader(InputStreamReader(stderr)).use { br ->
                while ((br.readLine().also { line = it }) != null) {
                    out += line
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, e.stackTraceToString())
        }
        return out
    }
}