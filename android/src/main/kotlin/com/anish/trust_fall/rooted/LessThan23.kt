package com.anish.trust_fall.rooted

import java.io.File

class LessThan23 : CheckApiVersion {

    override fun checkRooted(): Boolean {
        return canExecuteCommand("/system/xbin/which su") || isSuperuserPresent
    }

    companion object {
        // executes a command on the system
        private fun canExecuteCommand(command: String): Boolean {
            var process: Process? = null
            val executeResult: Boolean = try {
                process = Runtime.getRuntime().exec(command)
                process.waitFor() == 0
            } catch (e: Exception) {
                false
            } finally {
                runCatching { process?.inputStream?.close() }
                runCatching { process?.outputStream?.close() }
                runCatching { process?.errorStream?.close() }
                process?.destroy()
            }
            return executeResult
        }

        // Check if /system/app/Superuser.apk is present
        private val isSuperuserPresent: Boolean
            get() {
                // Check if /system/app/Superuser.apk is present
                for (path in SU_PATHS) {
                    if (File(path).exists()) {
                        return true
                    }
                }
                return false
            }
    }
}