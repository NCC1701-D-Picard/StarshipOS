/*
 * Copyright (c) 2006, 2024, Oracle and/or its affiliates. All rights reserved.
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

/*
 * @test
 * @bug 4733558 6471539
 * @summary Tests Timestamp encoding
 * @run main/othervm java_sql_Timestamp
 * @author Sergey Malenkov
 * @modules java.desktop
 *          java.sql
 */

import java.sql.Timestamp;

public final class java_sql_Timestamp extends AbstractTest<Timestamp> {
    public static void main(String[] args) {
        new java_sql_Timestamp().test();
    }

    protected Timestamp getObject() {
        Timestamp timestamp = new Timestamp(System.currentTimeMillis());
        timestamp.setNanos(1 + timestamp.getNanos());
        return timestamp;
    }

    protected Timestamp getAnotherObject() {
        return new Timestamp(0L);
    }
}