/*
 * Copyright (c) 2010, 2024, Oracle and/or its affiliates. All rights reserved.
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

import javax.swing.UIDefaults;

/*
 * @test
 * @bug 6622002
 * @summary UIDefault.ProxyLazyValue has unsafe reflection usage
 * @run main bug6622002
 */

public class bug6622002 {
     public static void main(String[] args) {

         if (createPublicValue() == null) {
             throw new RuntimeException("The public value unexpectedly wasn't created");
         }
     }

    private static Object createPublicValue() {
        return new UIDefaults.ProxyLazyValue(
            "javax.swing.UIDefaults").createValue(null);
    }
}