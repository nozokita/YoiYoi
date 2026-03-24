/**
 * SPEC.md: リアクション正常 / 二重拒否 / 不正値拒否 など 8 ケース。
 * 実行: cd FirestoreRulesTests && npm install && npm test
 */
const { readFileSync } = require('fs');
const { resolve } = require('path');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const {
  doc,
  setDoc,
  getDoc,
  updateDoc,
  Timestamp,
  increment,
  arrayUnion,
} = require('firebase/firestore');

function feedData(uid, overrides = {}) {
  return {
    uid,
    type: 'goal_met',
    actual_grams: 20,
    goal_grams: 40,
    percentage: 50,
    drinks: ['beer'],
    streak_days: 1,
    message_variant: 0,
    language: 'ja',
    reactions: { clap: 0, fire: 0, muscle: 0, hug: 0, clover: 0, cheers: 0 },
    reacted_uids: [],
    created_at: Timestamp.now(),
    ...overrides,
  };
}

async function run() {
  const rules = readFileSync(resolve(__dirname, '..', 'firestore.rules'), 'utf8');
  const testEnv = await initializeTestEnvironment({
    projectId: 'demo-yoiyoi-rules',
    firestore: { rules },
  });

  try {
    // 1: 認証ユーザーは自分の uid で feed を作成できる
    const alice = testEnv.authenticatedContext('alice').firestore();
    await assertSucceeds(
      setDoc(doc(alice, 'feed', 'post_alice'), feedData('alice'))
    );

    // 2: 他人の uid では feed を作成できない
    await assertFails(
      setDoc(doc(alice, 'feed', 'post_bad'), feedData('bob'))
    );

    // 3: 未認証では feed を読めない
    const guest = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(guest, 'feed', 'post_alice')));

    // 4: 認証ユーザーは feed を読める
    await assertSucceeds(getDoc(doc(alice, 'feed', 'post_alice')));

    // 5: 別ユーザーがリアクション（+1 と arrayUnion）できる
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await setDoc(doc(db, 'feed', 'post_rx'), feedData('alice'));
    });
    const bob = testEnv.authenticatedContext('bob').firestore();
    await assertSucceeds(
      updateDoc(doc(bob, 'feed', 'post_rx'), {
        'reactions.clap': increment(1),
        reacted_uids: arrayUnion('bob'),
      })
    );

    // 6: 同一ユーザーの二重リアクションは拒否
    await assertFails(
      updateDoc(doc(bob, 'feed', 'post_rx'), {
        'reactions.fire': increment(1),
        reacted_uids: arrayUnion('bob'),
      })
    );

    // 7: 複数キーを同時に増やす更新は拒否
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await setDoc(doc(db, 'feed', 'post_multi'), feedData('alice'));
    });
    const carol = testEnv.authenticatedContext('carol').firestore();
    await assertFails(
      updateDoc(doc(carol, 'feed', 'post_multi'), {
        'reactions.clap': increment(1),
        'reactions.fire': increment(1),
        reacted_uids: arrayUnion('carol'),
      })
    );

    // 8: users は本人のみ書き込み可
    await assertSucceeds(
      setDoc(doc(alice, 'users', 'alice'), {
        nickname_flag: '🇯🇵',
        nickname_emoji: '🌙',
        nickname_adjective: 'ほろよい',
        nickname_noun: 'ペンギン',
        language: 'ja',
        created_at: Timestamp.now(),
      })
    );
    await assertFails(
      setDoc(doc(alice, 'users', 'bob'), {
        nickname_flag: '🇺🇸',
        nickname_emoji: '⭐',
        nickname_adjective: 'Chill',
        nickname_noun: 'Fox',
        language: 'en',
        created_at: Timestamp.now(),
      })
    );

    // eslint-disable-next-line no-console
    console.log('firestore-rules.test.js: 8 tests passed');
  } finally {
    await testEnv.cleanup();
  }
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
