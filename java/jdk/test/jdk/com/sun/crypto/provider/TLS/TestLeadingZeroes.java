/*
 * Copyright (c) 2013, 2024, Oracle and/or its affiliates. All rights reserved.
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
 * @bug 8014618
 * @summary Need to strip leading zeros in TlsPremasterSecret of DHKeyAgreement
 * @author Pasi Eronen
 */

import java.io.*;
import java.security.*;
import java.security.spec.*;
import java.security.interfaces.*;
import java.util.HexFormat;
import javax.crypto.*;
import javax.crypto.spec.*;
import javax.crypto.interfaces.*;

/**
 * Test that leading zeroes are stripped in TlsPremasterSecret case,
 * but are left as-is in other cases.
 *
 * We use pre-generated keypairs, since with randomly generated keypairs,
 * a leading zero happens only (roughly) 1 out of 256 cases.
 */

public class TestLeadingZeroes {

    private static final String PROVIDER_NAME =
                            System.getProperty("test.provider.name", "SunJCE");
    // Hex formatter to upper case with ":" delimiter
    private static final HexFormat HEX_FORMATTER = HexFormat.ofDelimiter(":").withUpperCase();

    private TestLeadingZeroes() {}

    public static void main(String argv[]) throws Exception {
        TestLeadingZeroes keyAgree = new TestLeadingZeroes();
        keyAgree.run();
        System.out.println("Test Passed");
    }

    private void run() throws Exception {

        // decode pre-generated keypairs
        KeyFactory kfac = KeyFactory.getInstance("DH");
        PublicKey alicePubKey =
            kfac.generatePublic(new X509EncodedKeySpec(alicePubKeyEnc));
        PublicKey bobPubKey =
            kfac.generatePublic(new X509EncodedKeySpec(bobPubKeyEnc));
        PrivateKey alicePrivKey =
            kfac.generatePrivate(new PKCS8EncodedKeySpec(alicePrivKeyEnc));
        PrivateKey bobPrivKey =
            kfac.generatePrivate(new PKCS8EncodedKeySpec(bobPrivKeyEnc));

        // generate normal shared secret
        KeyAgreement aliceKeyAgree = KeyAgreement.getInstance("DH", PROVIDER_NAME);
        aliceKeyAgree.init(alicePrivKey);
        aliceKeyAgree.doPhase(bobPubKey, true);
        byte[] sharedSecret = aliceKeyAgree.generateSecret();
        System.out.println("shared secret:\n" + HEX_FORMATTER.formatHex(sharedSecret));

        // verify that leading zero is present
        if (sharedSecret.length != 256) {
            throw new Exception("Unexpected shared secret length");
        }
        if (sharedSecret[0] != 0) {
            throw new Exception("First byte is not zero as expected");
        }

        // now, test TLS premaster secret
        aliceKeyAgree.init(alicePrivKey);
        aliceKeyAgree.doPhase(bobPubKey, true);
        byte[] tlsPremasterSecret =
            aliceKeyAgree.generateSecret("TlsPremasterSecret").getEncoded();
        System.out.println(
            "tls premaster secret:\n" + HEX_FORMATTER.formatHex(tlsPremasterSecret));

        // check that leading zero has been stripped
        if (tlsPremasterSecret.length != 255) {
            throw new Exception("Unexpected TLS premaster secret length");
        }
        if (tlsPremasterSecret[0] == 0) {
            throw new Exception("First byte is zero");
        }
        for (int i = 0; i < tlsPremasterSecret.length; i++) {
            if (tlsPremasterSecret[i] != sharedSecret[i+1]) {
                throw new Exception("Shared secrets differ");
            }
        }

    }

    private static final byte alicePubKeyEnc[] = {
        (byte)0x30, (byte)0x82, (byte)0x02, (byte)0x25,
        (byte)0x30, (byte)0x82, (byte)0x01, (byte)0x17,
        (byte)0x06, (byte)0x09, (byte)0x2a, (byte)0x86,
        (byte)0x48, (byte)0x86, (byte)0xf7, (byte)0x0d,
        (byte)0x01, (byte)0x03, (byte)0x01, (byte)0x30,
        (byte)0x82, (byte)0x01, (byte)0x08, (byte)0x02,
        (byte)0x82, (byte)0x01, (byte)0x01, (byte)0x00,
        (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff,
        (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff,
        (byte)0xad, (byte)0xf8, (byte)0x54, (byte)0x58,
        (byte)0xa2, (byte)0xbb, (byte)0x4a, (byte)0x9a,
        (byte)0xaf, (byte)0xdc, (byte)0x56, (byte)0x20,
        (byte)0x27, (byte)0x3d, (byte)0x3c, (byte)0xf1,
        (byte)0xd8, (byte)0xb9, (byte)0xc5, (byte)0x83,
        (byte)0xce, (byte)0x2d, (byte)0x36, (byte)0x95,
        (byte)0xa9, (byte)0xe1, (byte)0x36, (byte)0x41,
        (byte)0x14, (byte)0x64, (byte)0x33, (byte)0xfb,
        (byte)0xcc, (byte)0x93, (byte)0x9d, (byte)0xce,
        (byte)0x24, (byte)0x9b, (byte)0x3e, (byte)0xf9,
        (byte)0x7d, (byte)0x2f, (byte)0xe3, (byte)0x63,
        (byte)0x63, (byte)0x0c, (byte)0x75, (byte)0xd8,
        (byte)0xf6, (byte)0x81, (byte)0xb2, (byte)0x02,
        (byte)0xae, (byte)0xc4, (byte)0x61, (byte)0x7a,
        (byte)0xd3, (byte)0xdf, (byte)0x1e, (byte)0xd5,
        (byte)0xd5, (byte)0xfd, (byte)0x65, (byte)0x61,
        (byte)0x24, (byte)0x33, (byte)0xf5, (byte)0x1f,
        (byte)0x5f, (byte)0x06, (byte)0x6e, (byte)0xd0,
        (byte)0x85, (byte)0x63, (byte)0x65, (byte)0x55,
        (byte)0x3d, (byte)0xed, (byte)0x1a, (byte)0xf3,
        (byte)0xb5, (byte)0x57, (byte)0x13, (byte)0x5e,
        (byte)0x7f, (byte)0x57, (byte)0xc9, (byte)0x35,
        (byte)0x98, (byte)0x4f, (byte)0x0c, (byte)0x70,
        (byte)0xe0, (byte)0xe6, (byte)0x8b, (byte)0x77,
        (byte)0xe2, (byte)0xa6, (byte)0x89, (byte)0xda,
        (byte)0xf3, (byte)0xef, (byte)0xe8, (byte)0x72,
        (byte)0x1d, (byte)0xf1, (byte)0x58, (byte)0xa1,
        (byte)0x36, (byte)0xad, (byte)0xe7, (byte)0x35,
        (byte)0x30, (byte)0xac, (byte)0xca, (byte)0x4f,
        (byte)0x48, (byte)0x3a, (byte)0x79, (byte)0x7a,
        (byte)0xbc, (byte)0x0a, (byte)0xb1, (byte)0x82,
        (byte)0xb3, (byte)0x24, (byte)0xfb, (byte)0x61,
        (byte)0xd1, (byte)0x08, (byte)0xa9, (byte)0x4b,
        (byte)0xb2, (byte)0xc8, (byte)0xe3, (byte)0xfb,
        (byte)0xb9, (byte)0x6a, (byte)0xda, (byte)0xb7,
        (byte)0x60, (byte)0xd7, (byte)0xf4, (byte)0x68,
        (byte)0x1d, (byte)0x4f, (byte)0x42, (byte)0xa3,
        (byte)0xde, (byte)0x39, (byte)0x4d, (byte)0xf4,
        (byte)0xae, (byte)0x56, (byte)0xed, (byte)0xe7,
        (byte)0x63, (byte)0x72, (byte)0xbb, (byte)0x19,
        (byte)0x0b, (byte)0x07, (byte)0xa7, (byte)0xc8,
        (byte)0xee, (byte)0x0a, (byte)0x6d, (byte)0x70,
        (byte)0x9e, (byte)0x02, (byte)0xfc, (byte)0xe1,
        (byte)0xcd, (byte)0xf7, (byte)0xe2, (byte)0xec,
        (byte)0xc0, (byte)0x34, (byte)0x04, (byte)0xcd,
        (byte)0x28, (byte)0x34, (byte)0x2f, (byte)0x61,
        (byte)0x91, (byte)0x72, (byte)0xfe, (byte)0x9c,
        (byte)0xe9, (byte)0x85, (byte)0x83, (byte)0xff,
        (byte)0x8e, (byte)0x4f, (byte)0x12, (byte)0x32,
        (byte)0xee, (byte)0xf2, (byte)0x81, (byte)0x83,
        (byte)0xc3, (byte)0xfe, (byte)0x3b, (byte)0x1b,
        (byte)0x4c, (byte)0x6f, (byte)0xad, (byte)0x73,
        (byte)0x3b, (byte)0xb5, (byte)0xfc, (byte)0xbc,
        (byte)0x2e, (byte)0xc2, (byte)0x20, (byte)0x05,
        (byte)0xc5, (byte)0x8e, (byte)0xf1, (byte)0x83,
        (byte)0x7d, (byte)0x16, (byte)0x83, (byte)0xb2,
        (byte)0xc6, (byte)0xf3, (byte)0x4a, (byte)0x26,
        (byte)0xc1, (byte)0xb2, (byte)0xef, (byte)0xfa,
        (byte)0x88, (byte)0x6b, (byte)0x42, (byte)0x38,
        (byte)0x61, (byte)0x28, (byte)0x5c, (byte)0x97,
        (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff,
        (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff,
        (byte)0x02, (byte)0x01, (byte)0x02, (byte)0x03,
        (byte)0x82, (byte)0x01, (byte)0x06, (byte)0x00,
        (byte)0x02, (byte)0x82, (byte)0x01, (byte)0x01,
        (byte)0x00, (byte)0xb0, (byte)0x6e, (byte)0x76,
        (byte)0x73, (byte)0x32, (byte)0xd4, (byte)0xcf,
        (byte)0xb8, (byte)0x16, (byte)0x46, (byte)0x76,
        (byte)0x8b, (byte)0x2b, (byte)0x2b, (byte)0xda,
        (byte)0x6e, (byte)0x25, (byte)0x52, (byte)0x87,
        (byte)0x9e, (byte)0x0c, (byte)0x97, (byte)0xc7,
        (byte)0x16, (byte)0x42, (byte)0xb6, (byte)0x30,
        (byte)0xc6, (byte)0x30, (byte)0xce, (byte)0xc5,
        (byte)0xf4, (byte)0x8e, (byte)0x28, (byte)0xe0,
        (byte)0x8d, (byte)0x5b, (byte)0x44, (byte)0x59,
        (byte)0xae, (byte)0x5e, (byte)0xb6, (byte)0x5f,
        (byte)0x48, (byte)0x8e, (byte)0x13, (byte)0x91,
        (byte)0x00, (byte)0x72, (byte)0x9b, (byte)0x1b,
        (byte)0xd8, (byte)0x69, (byte)0xe4, (byte)0xdf,
        (byte)0x10, (byte)0x50, (byte)0x53, (byte)0x0f,
        (byte)0x3d, (byte)0xba, (byte)0x82, (byte)0x02,
        (byte)0x1c, (byte)0x78, (byte)0xf3, (byte)0xf3,
        (byte)0x9a, (byte)0x01, (byte)0x3d, (byte)0xb6,
        (byte)0x65, (byte)0xc2, (byte)0x6f, (byte)0x70,
        (byte)0xec, (byte)0x67, (byte)0x14, (byte)0x56,
        (byte)0xa0, (byte)0x98, (byte)0xef, (byte)0xc8,
        (byte)0x63, (byte)0xbe, (byte)0x14, (byte)0x78,
        (byte)0x1d, (byte)0xff, (byte)0xf8, (byte)0xf9,
        (byte)0xd9, (byte)0x53, (byte)0xb2, (byte)0xc4,
        (byte)0x40, (byte)0x3e, (byte)0x90, (byte)0x5c,
        (byte)0x10, (byte)0xf8, (byte)0xa4, (byte)0xd3,
        (byte)0xa2, (byte)0x39, (byte)0xc6, (byte)0xeb,
        (byte)0xcd, (byte)0x3d, (byte)0xd1, (byte)0x27,
        (byte)0x51, (byte)0xc8, (byte)0x4f, (byte)0x9b,
        (byte)0x86, (byte)0xce, (byte)0xcf, (byte)0x80,
        (byte)0x96, (byte)0x3d, (byte)0xb9, (byte)0x25,
        (byte)0x05, (byte)0x54, (byte)0x15, (byte)0x8d,
        (byte)0x02, (byte)0xd2, (byte)0x6f, (byte)0xed,
        (byte)0xaf, (byte)0x49, (byte)0x0d, (byte)0x3e,
        (byte)0xda, (byte)0xe6, (byte)0x3d, (byte)0x1a,
        (byte)0x91, (byte)0x8f, (byte)0xca, (byte)0x6d,
        (byte)0x88, (byte)0xff, (byte)0x0f, (byte)0x75,
        (byte)0xf5, (byte)0x4e, (byte)0x08, (byte)0x42,
        (byte)0xf0, (byte)0xa3, (byte)0x4a, (byte)0x95,
        (byte)0xca, (byte)0x18, (byte)0xc1, (byte)0x3d,
        (byte)0x9a, (byte)0x12, (byte)0x3e, (byte)0x09,
        (byte)0x29, (byte)0x82, (byte)0x8e, (byte)0xe5,
        (byte)0x3a, (byte)0x4c, (byte)0xcc, (byte)0x8f,
        (byte)0x94, (byte)0x14, (byte)0xe3, (byte)0xc7,
        (byte)0x63, (byte)0x8a, (byte)0x23, (byte)0x11,
        (byte)0x03, (byte)0x77, (byte)0x7d, (byte)0xe8,
        (byte)0x03, (byte)0x15, (byte)0x37, (byte)0xa9,
        (byte)0xe5, (byte)0xd7, (byte)0x38, (byte)0x8f,
        (byte)0xa8, (byte)0x49, (byte)0x5d, (byte)0xe4,
        (byte)0x0d, (byte)0xed, (byte)0xb9, (byte)0x92,
        (byte)0xc4, (byte)0xd7, (byte)0x72, (byte)0xf2,
        (byte)0x29, (byte)0x26, (byte)0x99, (byte)0x11,
        (byte)0xac, (byte)0xa8, (byte)0x45, (byte)0xb1,
        (byte)0x6b, (byte)0x5a, (byte)0x01, (byte)0xc4,
        (byte)0xe0, (byte)0x08, (byte)0xbf, (byte)0xa1,
        (byte)0x49, (byte)0x2a, (byte)0x9c, (byte)0x8c,
        (byte)0x89, (byte)0x31, (byte)0x07, (byte)0x36,
        (byte)0x7d, (byte)0xec, (byte)0xa3, (byte)0x9a,
        (byte)0x1e, (byte)0xd6, (byte)0xc6, (byte)0x01,
        (byte)0x0e, (byte)0xc8, (byte)0x85, (byte)0x55,
        (byte)0x42, (byte)0xa4, (byte)0x87, (byte)0x58,
        (byte)0xfa, (byte)0xec, (byte)0x71, (byte)0x2e,
        (byte)0x4c, (byte)0x46, (byte)0xd2, (byte)0x19,
        (byte)0x23, (byte)0x0a, (byte)0x59, (byte)0x1a,
        (byte)0x56
    };

    private static final byte alicePrivKeyEnc[] = {
        (byte)0x30, (byte)0x82, (byte)0x01, (byte)0x3f,
        (byte)0x02, (byte)0x01, (byte)0x00, (byte)0x30,
        (byte)0x82, (byte)0x01, (byte)0x17, (byte)0x06,
        (byte)0x09, (byte)0x2a, (byte)0x86, (byte)0x48,
        (byte)0x86, (byte)0xf7, (byte)0x0d, (byte)0x01,
        (byte)0x03, (byte)0x01, (byte)0x30, (byte)0x82,
        (byte)0x01, (byte)0x08, (byte)0x02, (byte)0x82,
        (byte)0x01, (byte)0x01, (byte)0x00, (byte)0xff,
        (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff,
        (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xad,
        (byte)0xf8, (byte)0x54, (byte)0x58, (byte)0xa2,
        (byte)0xbb, (byte)0x4a, (byte)0x9a, (byte)0xaf,
        (byte)0xdc, (byte)0x56, (byte)0x20, (byte)0x27,
        (byte)0x3d, (byte)0x3c, (byte)0xf1, (byte)0xd8,
        (byte)0xb9, (byte)0xc5, (byte)0x83, (byte)0xce,
        (byte)0x2d, (byte)0x36, (byte)0x95, (byte)0xa9,
        (byte)0xe1, (byte)0x36, (byte)0x41, (byte)0x14,
        (byte)0x64, (byte)0x33, (byte)0xfb, (byte)0xcc,
        (byte)0x93, (byte)0x9d, (byte)0xce, (byte)0x24,
        (byte)0x9b, (byte)0x3e, (byte)0xf9, (byte)0x7d,
        (byte)0x2f, (byte)0xe3, (byte)0x63, (byte)0x63,
        (byte)0x0c, (byte)0x75, (byte)0xd8, (byte)0xf6,
        (byte)0x81, (byte)0xb2, (byte)0x02, (byte)0xae,
        (byte)0xc4, (byte)0x61, (byte)0x7a, (byte)0xd3,
        (byte)0xdf, (byte)0x1e, (byte)0xd5, (byte)0xd5,
        (byte)0xfd, (byte)0x65, (byte)0x61, (byte)0x24,
        (byte)0x33, (byte)0xf5, (byte)0x1f, (byte)0x5f,
        (byte)0x06, (byte)0x6e, (byte)0xd0, (byte)0x85,
        (byte)0x63, (byte)0x65, (byte)0x55, (byte)0x3d,
        (byte)0xed, (byte)0x1a, (byte)0xf3, (byte)0xb5,
        (byte)0x57, (byte)0x13, (byte)0x5e, (byte)0x7f,
        (byte)0x57, (byte)0xc9, (byte)0x35, (byte)0x98,
        (byte)0x4f, (byte)0x0c, (byte)0x70, (byte)0xe0,
        (byte)0xe6, (byte)0x8b, (byte)0x77, (byte)0xe2,
        (byte)0xa6, (byte)0x89, (byte)0xda, (byte)0xf3,
        (byte)0xef, (byte)0xe8, (byte)0x72, (byte)0x1d,
        (byte)0xf1, (byte)0x58, (byte)0xa1, (byte)0x36,
        (byte)0xad, (byte)0xe7, (byte)0x35, (byte)0x30,
        (byte)0xac, (byte)0xca, (byte)0x4f, (byte)0x48,
        (byte)0x3a, (byte)0x79, (byte)0x7a, (byte)0xbc,
        (byte)0x0a, (byte)0xb1, (byte)0x82, (byte)0xb3,
        (byte)0x24, (byte)0xfb, (byte)0x61, (byte)0xd1,
        (byte)0x08, (byte)0xa9, (byte)0x4b, (byte)0xb2,
        (byte)0xc8, (byte)0xe3, (byte)0xfb, (byte)0xb9,
        (byte)0x6a, (byte)0xda, (byte)0xb7, (byte)0x60,
        (byte)0xd7, (byte)0xf4, (byte)0x68, (byte)0x1d,
        (byte)0x4f, (byte)0x42, (byte)0xa3, (byte)0xde,
        (byte)0x39, (byte)0x4d, (byte)0xf4, (byte)0xae,
        (byte)0x56, (byte)0xed, (byte)0xe7, (byte)0x63,
        (byte)0x72, (byte)0xbb, (byte)0x19, (byte)0x0b,
        (byte)0x07, (byte)0xa7, (byte)0xc8, (byte)0xee,
        (byte)0x0a, (byte)0x6d, (byte)0x70, (byte)0x9e,
        (byte)0x02, (byte)0xfc, (byte)0xe1, (byte)0xcd,
        (byte)0xf7, (byte)0xe2, (byte)0xec, (byte)0xc0,
        (byte)0x34, (byte)0x04, (byte)0xcd, (byte)0x28,
        (byte)0x34, (byte)0x2f, (byte)0x61, (byte)0x91,
        (byte)0x72, (byte)0xfe, (byte)0x9c, (byte)0xe9,
        (byte)0x85, (byte)0x83, (byte)0xff, (byte)0x8e,
        (byte)0x4f, (byte)0x12, (byte)0x32, (byte)0xee,
        (byte)0xf2, (byte)0x81, (byte)0x83, (byte)0xc3,
        (byte)0xfe, (byte)0x3b, (byte)0x1b, (byte)0x4c,
        (byte)0x6f, (byte)0xad, (byte)0x73, (byte)0x3b,
        (byte)0xb5, (byte)0xfc, (byte)0xbc, (byte)0x2e,
        (byte)0xc2, (byte)0x20, (byte)0x05, (byte)0xc5,
        (byte)0x8e, (byte)0xf1, (byte)0x83, (byte)0x7d,
        (byte)0x16, (byte)0x83, (byte)0xb2, (byte)0xc6,
        (byte)0xf3, (byte)0x4a, (byte)0x26, (byte)0xc1,
        (byte)0xb2, (byte)0xef, (byte)0xfa, (byte)0x88,
        (byte)0x6b, (byte)0x42, (byte)0x38, (byte)0x61,
        (byte)0x28, (byte)0x5c, (byte)0x97, (byte)0xff,
        (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff,
        (byte)0xff, (byte)0xff, (byte)0xff, (byte)0x02,
        (byte)0x01, (byte)0x02, (byte)0x04, (byte)0x1f,
        (byte)0x02, (byte)0x1d, (byte)0x00, (byte)0xc7,
        (byte)0x06, (byte)0xe9, (byte)0x24, (byte)0xf8,
        (byte)0xb1, (byte)0xdf, (byte)0x98, (byte)0x61,
        (byte)0x34, (byte)0x7f, (byte)0xcf, (byte)0xf1,
        (byte)0xcc, (byte)0xcd, (byte)0xc8, (byte)0xcc,
        (byte)0xd9, (byte)0x6a, (byte)0xb8, (byte)0x7d,
        (byte)0x72, (byte)0x4c, (byte)0x58, (byte)0x5a,
        (byte)0x97, (byte)0x39, (byte)0x69
    };

    private static final byte bobPubKeyEnc[] = {
        (byte)0x30, (byte)0x82, (byte)0x02, (byte)0x25,
        (byte)0x30, (byte)0x82, (byte)0x01, (byte)0x17,
        (byte)0x06, (byte)0x09, (byte)0x2a, (byte)0x86,
        (byte)0x48, (byte)0x86, (byte)0xf7, (byte)0x0d,
        (byte)0x01, (byte)0x03, (byte)0x01, (byte)0x30,
        (byte)0x82, (byte)0x01, (byte)0x08, (byte)0x02,
        (byte)0x82, (byte)0x01, (byte)0x01, (byte)0x00,
        (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff,
        (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff,
        (byte)0xad, (byte)0xf8, (byte)0x54, (byte)0x58,
        (byte)0xa2, (byte)0xbb, (byte)0x4a, (byte)0x9a,
        (byte)0xaf, (byte)0xdc, (byte)0x56, (byte)0x20,
        (byte)0x27, (byte)0x3d, (byte)0x3c, (byte)0xf1,
        (byte)0xd8, (byte)0xb9, (byte)0xc5, (byte)0x83,
        (byte)0xce, (byte)0x2d, (byte)0x36, (byte)0x95,
        (byte)0xa9, (byte)0xe1, (byte)0x36, (byte)0x41,
        (byte)0x14, (byte)0x64, (byte)0x33, (byte)0xfb,
        (byte)0xcc, (byte)0x93, (byte)0x9d, (byte)0xce,
        (byte)0x24, (byte)0x9b, (byte)0x3e, (byte)0xf9,
        (byte)0x7d, (byte)0x2f, (byte)0xe3, (byte)0x63,
        (byte)0x63, (byte)0x0c, (byte)0x75, (byte)0xd8,
        (byte)0xf6, (byte)0x81, (byte)0xb2, (byte)0x02,
        (byte)0xae, (byte)0xc4, (byte)0x61, (byte)0x7a,
        (byte)0xd3, (byte)0xdf, (byte)0x1e, (byte)0xd5,
        (byte)0xd5, (byte)0xfd, (byte)0x65, (byte)0x61,
        (byte)0x24, (byte)0x33, (byte)0xf5, (byte)0x1f,
        (byte)0x5f, (byte)0x06, (byte)0x6e, (byte)0xd0,
        (byte)0x85, (byte)0x63, (byte)0x65, (byte)0x55,
        (byte)0x3d, (byte)0xed, (byte)0x1a, (byte)0xf3,
        (byte)0xb5, (byte)0x57, (byte)0x13, (byte)0x5e,
        (byte)0x7f, (byte)0x57, (byte)0xc9, (byte)0x35,
        (byte)0x98, (byte)0x4f, (byte)0x0c, (byte)0x70,
        (byte)0xe0, (byte)0xe6, (byte)0x8b, (byte)0x77,
        (byte)0xe2, (byte)0xa6, (byte)0x89, (byte)0xda,
        (byte)0xf3, (byte)0xef, (byte)0xe8, (byte)0x72,
        (byte)0x1d, (byte)0xf1, (byte)0x58, (byte)0xa1,
        (byte)0x36, (byte)0xad, (byte)0xe7, (byte)0x35,
        (byte)0x30, (byte)0xac, (byte)0xca, (byte)0x4f,
        (byte)0x48, (byte)0x3a, (byte)0x79, (byte)0x7a,
        (byte)0xbc, (byte)0x0a, (byte)0xb1, (byte)0x82,
        (byte)0xb3, (byte)0x24, (byte)0xfb, (byte)0x61,
        (byte)0xd1, (byte)0x08, (byte)0xa9, (byte)0x4b,
        (byte)0xb2, (byte)0xc8, (byte)0xe3, (byte)0xfb,
        (byte)0xb9, (byte)0x6a, (byte)0xda, (byte)0xb7,
        (byte)0x60, (byte)0xd7, (byte)0xf4, (byte)0x68,
        (byte)0x1d, (byte)0x4f, (byte)0x42, (byte)0xa3,
        (byte)0xde, (byte)0x39, (byte)0x4d, (byte)0xf4,
        (byte)0xae, (byte)0x56, (byte)0xed, (byte)0xe7,
        (byte)0x63, (byte)0x72, (byte)0xbb, (byte)0x19,
        (byte)0x0b, (byte)0x07, (byte)0xa7, (byte)0xc8,
        (byte)0xee, (byte)0x0a, (byte)0x6d, (byte)0x70,
        (byte)0x9e, (byte)0x02, (byte)0xfc, (byte)0xe1,
        (byte)0xcd, (byte)0xf7, (byte)0xe2, (byte)0xec,
        (byte)0xc0, (byte)0x34, (byte)0x04, (byte)0xcd,
        (byte)0x28, (byte)0x34, (byte)0x2f, (byte)0x61,
        (byte)0x91, (byte)0x72, (byte)0xfe, (byte)0x9c,
        (byte)0xe9, (byte)0x85, (byte)0x83, (byte)0xff,
        (byte)0x8e, (byte)0x4f, (byte)0x12, (byte)0x32,
        (byte)0xee, (byte)0xf2, (byte)0x81, (byte)0x83,
        (byte)0xc3, (byte)0xfe, (byte)0x3b, (byte)0x1b,
        (byte)0x4c, (byte)0x6f, (byte)0xad, (byte)0x73,
        (byte)0x3b, (byte)0xb5, (byte)0xfc, (byte)0xbc,
        (byte)0x2e, (byte)0xc2, (byte)0x20, (byte)0x05,
        (byte)0xc5, (byte)0x8e, (byte)0xf1, (byte)0x83,
        (byte)0x7d, (byte)0x16, (byte)0x83, (byte)0xb2,
        (byte)0xc6, (byte)0xf3, (byte)0x4a, (byte)0x26,
        (byte)0xc1, (byte)0xb2, (byte)0xef, (byte)0xfa,
        (byte)0x88, (byte)0x6b, (byte)0x42, (byte)0x38,
        (byte)0x61, (byte)0x28, (byte)0x5c, (byte)0x97,
        (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff,
        (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff,
        (byte)0x02, (byte)0x01, (byte)0x02, (byte)0x03,
        (byte)0x82, (byte)0x01, (byte)0x06, (byte)0x00,
        (byte)0x02, (byte)0x82, (byte)0x01, (byte)0x01,
        (byte)0x00, (byte)0x8d, (byte)0xb4, (byte)0x1c,
        (byte)0xfc, (byte)0xc0, (byte)0x5f, (byte)0x38,
        (byte)0x4c, (byte)0x7f, (byte)0x31, (byte)0xaa,
        (byte)0x03, (byte)0x06, (byte)0xf0, (byte)0xec,
        (byte)0xfd, (byte)0x45, (byte)0x8d, (byte)0x69,
        (byte)0x8a, (byte)0xb6, (byte)0x60, (byte)0x2f,
        (byte)0xa2, (byte)0xb4, (byte)0xda, (byte)0xc0,
        (byte)0x2e, (byte)0xe1, (byte)0x31, (byte)0x12,
        (byte)0x5a, (byte)0x49, (byte)0xef, (byte)0xf7,
        (byte)0x17, (byte)0x77, (byte)0x26, (byte)0xa8,
        (byte)0x91, (byte)0x0b, (byte)0xbc, (byte)0x84,
        (byte)0x5c, (byte)0x20, (byte)0x84, (byte)0xd3,
        (byte)0x38, (byte)0xc9, (byte)0xa1, (byte)0x5b,
        (byte)0xad, (byte)0x84, (byte)0x83, (byte)0xb9,
        (byte)0xe1, (byte)0x59, (byte)0x87, (byte)0xd9,
        (byte)0x9b, (byte)0x36, (byte)0x6b, (byte)0x3c,
        (byte)0xb6, (byte)0x3c, (byte)0x3a, (byte)0x0c,
        (byte)0xf4, (byte)0x0b, (byte)0xad, (byte)0x23,
        (byte)0x8d, (byte)0x5f, (byte)0x80, (byte)0x16,
        (byte)0xa3, (byte)0x96, (byte)0xbd, (byte)0x28,
        (byte)0x2f, (byte)0x9f, (byte)0xd1, (byte)0x7e,
        (byte)0x13, (byte)0x86, (byte)0x6a, (byte)0x22,
        (byte)0x26, (byte)0xdb, (byte)0x3b, (byte)0x42,
        (byte)0xf0, (byte)0x21, (byte)0x7a, (byte)0x6c,
        (byte)0xe3, (byte)0xb0, (byte)0x8d, (byte)0x9c,
        (byte)0x3b, (byte)0xfb, (byte)0x17, (byte)0x27,
        (byte)0xde, (byte)0xe4, (byte)0x82, (byte)0x2e,
        (byte)0x6d, (byte)0x08, (byte)0xeb, (byte)0x2b,
        (byte)0xb9, (byte)0xb0, (byte)0x94, (byte)0x0e,
        (byte)0x56, (byte)0xc1, (byte)0xf2, (byte)0x54,
        (byte)0xd8, (byte)0x94, (byte)0x21, (byte)0xc2,
        (byte)0x2d, (byte)0x4d, (byte)0x28, (byte)0xf2,
        (byte)0xc3, (byte)0x96, (byte)0x5b, (byte)0x24,
        (byte)0xb6, (byte)0xee, (byte)0xa4, (byte)0xbf,
        (byte)0x20, (byte)0x19, (byte)0x29, (byte)0x1a,
        (byte)0x55, (byte)0x46, (byte)0x7a, (byte)0x2a,
        (byte)0x14, (byte)0x12, (byte)0x4d, (byte)0xf4,
        (byte)0xee, (byte)0xf5, (byte)0x6f, (byte)0x4f,
        (byte)0xf7, (byte)0x99, (byte)0x1c, (byte)0xa3,
        (byte)0x72, (byte)0x33, (byte)0x7d, (byte)0xfe,
        (byte)0xae, (byte)0x0b, (byte)0xda, (byte)0x2c,
        (byte)0xc7, (byte)0xf3, (byte)0xba, (byte)0xb7,
        (byte)0x83, (byte)0x58, (byte)0x4c, (byte)0x93,
        (byte)0x5d, (byte)0x90, (byte)0x65, (byte)0xc9,
        (byte)0xb8, (byte)0x6d, (byte)0x2d, (byte)0xda,
        (byte)0x10, (byte)0x55, (byte)0xe6, (byte)0x27,
        (byte)0xb9, (byte)0x4b, (byte)0x75, (byte)0x30,
        (byte)0xfa, (byte)0xe4, (byte)0xa3, (byte)0xff,
        (byte)0xae, (byte)0xf9, (byte)0xfb, (byte)0xe4,
        (byte)0x62, (byte)0x89, (byte)0x7c, (byte)0x7d,
        (byte)0x20, (byte)0x50, (byte)0xf9, (byte)0xd1,
        (byte)0xe2, (byte)0x0e, (byte)0x56, (byte)0xf6,
        (byte)0x3c, (byte)0x8b, (byte)0x24, (byte)0x8a,
        (byte)0x6d, (byte)0x92, (byte)0x3f, (byte)0x85,
        (byte)0x7b, (byte)0x3b, (byte)0x49, (byte)0x21,
        (byte)0x9d, (byte)0x26, (byte)0x1b, (byte)0x58,
        (byte)0x08, (byte)0x9e, (byte)0x5f, (byte)0xea,
        (byte)0x23, (byte)0x20, (byte)0xc2, (byte)0x3d,
        (byte)0x87, (byte)0xbe, (byte)0x1a, (byte)0x17,
        (byte)0x34, (byte)0xd8, (byte)0x10, (byte)0x0f,
        (byte)0x81, (byte)0xb6, (byte)0xc7, (byte)0xa5,
        (byte)0xe9, (byte)0x8b, (byte)0x21, (byte)0xab,
        (byte)0x09, (byte)0x88, (byte)0x5e, (byte)0xbd,
        (byte)0xa2, (byte)0x8a, (byte)0xc4, (byte)0xa8,
        (byte)0x83
    };

    private static final byte bobPrivKeyEnc[] = {
        (byte)0x30, (byte)0x82, (byte)0x01, (byte)0x3f,
        (byte)0x02, (byte)0x01, (byte)0x00, (byte)0x30,
        (byte)0x82, (byte)0x01, (byte)0x17, (byte)0x06,
        (byte)0x09, (byte)0x2a, (byte)0x86, (byte)0x48,
        (byte)0x86, (byte)0xf7, (byte)0x0d, (byte)0x01,
        (byte)0x03, (byte)0x01, (byte)0x30, (byte)0x82,
        (byte)0x01, (byte)0x08, (byte)0x02, (byte)0x82,
        (byte)0x01, (byte)0x01, (byte)0x00, (byte)0xff,
        (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff,
        (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xad,
        (byte)0xf8, (byte)0x54, (byte)0x58, (byte)0xa2,
        (byte)0xbb, (byte)0x4a, (byte)0x9a, (byte)0xaf,
        (byte)0xdc, (byte)0x56, (byte)0x20, (byte)0x27,
        (byte)0x3d, (byte)0x3c, (byte)0xf1, (byte)0xd8,
        (byte)0xb9, (byte)0xc5, (byte)0x83, (byte)0xce,
        (byte)0x2d, (byte)0x36, (byte)0x95, (byte)0xa9,
        (byte)0xe1, (byte)0x36, (byte)0x41, (byte)0x14,
        (byte)0x64, (byte)0x33, (byte)0xfb, (byte)0xcc,
        (byte)0x93, (byte)0x9d, (byte)0xce, (byte)0x24,
        (byte)0x9b, (byte)0x3e, (byte)0xf9, (byte)0x7d,
        (byte)0x2f, (byte)0xe3, (byte)0x63, (byte)0x63,
        (byte)0x0c, (byte)0x75, (byte)0xd8, (byte)0xf6,
        (byte)0x81, (byte)0xb2, (byte)0x02, (byte)0xae,
        (byte)0xc4, (byte)0x61, (byte)0x7a, (byte)0xd3,
        (byte)0xdf, (byte)0x1e, (byte)0xd5, (byte)0xd5,
        (byte)0xfd, (byte)0x65, (byte)0x61, (byte)0x24,
        (byte)0x33, (byte)0xf5, (byte)0x1f, (byte)0x5f,
        (byte)0x06, (byte)0x6e, (byte)0xd0, (byte)0x85,
        (byte)0x63, (byte)0x65, (byte)0x55, (byte)0x3d,
        (byte)0xed, (byte)0x1a, (byte)0xf3, (byte)0xb5,
        (byte)0x57, (byte)0x13, (byte)0x5e, (byte)0x7f,
        (byte)0x57, (byte)0xc9, (byte)0x35, (byte)0x98,
        (byte)0x4f, (byte)0x0c, (byte)0x70, (byte)0xe0,
        (byte)0xe6, (byte)0x8b, (byte)0x77, (byte)0xe2,
        (byte)0xa6, (byte)0x89, (byte)0xda, (byte)0xf3,
        (byte)0xef, (byte)0xe8, (byte)0x72, (byte)0x1d,
        (byte)0xf1, (byte)0x58, (byte)0xa1, (byte)0x36,
        (byte)0xad, (byte)0xe7, (byte)0x35, (byte)0x30,
        (byte)0xac, (byte)0xca, (byte)0x4f, (byte)0x48,
        (byte)0x3a, (byte)0x79, (byte)0x7a, (byte)0xbc,
        (byte)0x0a, (byte)0xb1, (byte)0x82, (byte)0xb3,
        (byte)0x24, (byte)0xfb, (byte)0x61, (byte)0xd1,
        (byte)0x08, (byte)0xa9, (byte)0x4b, (byte)0xb2,
        (byte)0xc8, (byte)0xe3, (byte)0xfb, (byte)0xb9,
        (byte)0x6a, (byte)0xda, (byte)0xb7, (byte)0x60,
        (byte)0xd7, (byte)0xf4, (byte)0x68, (byte)0x1d,
        (byte)0x4f, (byte)0x42, (byte)0xa3, (byte)0xde,
        (byte)0x39, (byte)0x4d, (byte)0xf4, (byte)0xae,
        (byte)0x56, (byte)0xed, (byte)0xe7, (byte)0x63,
        (byte)0x72, (byte)0xbb, (byte)0x19, (byte)0x0b,
        (byte)0x07, (byte)0xa7, (byte)0xc8, (byte)0xee,
        (byte)0x0a, (byte)0x6d, (byte)0x70, (byte)0x9e,
        (byte)0x02, (byte)0xfc, (byte)0xe1, (byte)0xcd,
        (byte)0xf7, (byte)0xe2, (byte)0xec, (byte)0xc0,
        (byte)0x34, (byte)0x04, (byte)0xcd, (byte)0x28,
        (byte)0x34, (byte)0x2f, (byte)0x61, (byte)0x91,
        (byte)0x72, (byte)0xfe, (byte)0x9c, (byte)0xe9,
        (byte)0x85, (byte)0x83, (byte)0xff, (byte)0x8e,
        (byte)0x4f, (byte)0x12, (byte)0x32, (byte)0xee,
        (byte)0xf2, (byte)0x81, (byte)0x83, (byte)0xc3,
        (byte)0xfe, (byte)0x3b, (byte)0x1b, (byte)0x4c,
        (byte)0x6f, (byte)0xad, (byte)0x73, (byte)0x3b,
        (byte)0xb5, (byte)0xfc, (byte)0xbc, (byte)0x2e,
        (byte)0xc2, (byte)0x20, (byte)0x05, (byte)0xc5,
        (byte)0x8e, (byte)0xf1, (byte)0x83, (byte)0x7d,
        (byte)0x16, (byte)0x83, (byte)0xb2, (byte)0xc6,
        (byte)0xf3, (byte)0x4a, (byte)0x26, (byte)0xc1,
        (byte)0xb2, (byte)0xef, (byte)0xfa, (byte)0x88,
        (byte)0x6b, (byte)0x42, (byte)0x38, (byte)0x61,
        (byte)0x28, (byte)0x5c, (byte)0x97, (byte)0xff,
        (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff,
        (byte)0xff, (byte)0xff, (byte)0xff, (byte)0x02,
        (byte)0x01, (byte)0x02, (byte)0x04, (byte)0x1f,
        (byte)0x02, (byte)0x1d, (byte)0x01, (byte)0x62,
        (byte)0x8e, (byte)0xfc, (byte)0xf3, (byte)0x25,
        (byte)0xf3, (byte)0x2a, (byte)0xf4, (byte)0x49,
        (byte)0x20, (byte)0x83, (byte)0x61, (byte)0x7f,
        (byte)0x97, (byte)0x8f, (byte)0x48, (byte)0xac,
        (byte)0xf9, (byte)0xc3, (byte)0xad, (byte)0x3c,
        (byte)0x56, (byte)0x95, (byte)0x1c, (byte)0x85,
        (byte)0xd3, (byte)0x85, (byte)0xd6
    };
}
