import * as admin from 'firebase-admin'
import axios from  'axios'
import * as functions from 'firebase-functions/v2'
import { firestore } from 'firebase-admin'
import Timestamp = firestore.Timestamp

admin.initializeApp()

/**
 * LINE アクセストークンを検証し、LINE プロフィール情報を取得して、Firebase Auth のカスタムトークンを生成し、ユーザードキュメントを設定する Firebase Functions の HTTPS Callable Function.
 * @param {Object} callableRequest - Firebase Functions から提供されるリクエストオブジェクト。
 * @param {string} callableRequest.data.accessToken - ユーザーから提供される LINE アクセストークン。
 * @returns {Promise<{customToken: string}>} 生成された Firebase Auth のカスタムトークンを含むオブジェクト。
 * @throws {Error} LINE アクセストークンの検証に失敗した場合、または LINE プロフィール情報の取得に失敗した場合、またはカスタムトークンの生成に失敗した場合、またはユーザードキュメントの設定に失敗した場合にエラーをスローする。
 */

export const createfirebaseauthcustomtoken = functions
// .region('asia-northeast2')
.https
.onCall<{accessToken: string, }>({region: 'asia-northeast2'},
    async(callableRequest) => {
        const accessToken = callableRequest.data.accessToken
        await verifyAccessToken(accessToken)
        const {lineUserId, name, imageUrl} = await getLINEProfile(accessToken)
        const customToken = await admin.auth().createCustomToken(lineUserId)
        // ID登録されてればスルー
        const userDoc = await admin.firestore().collection('users').doc(lineUserId).get()
        if (!userDoc.exists) {
            await setAppUserDocument({lineUserId, name, imageUrl})
        } else {
            console.log(`user is exists: ${lineUserId}`)
        }
        return {customToken}
    }
)

/**
 * LINE の Verify API を呼び出して、アクセストークンの有効性を確認する。
 * @param {string} accessToken - 検証する LINE のアクセストークン。
 * @throws {Error} API のレスポンスステータスが 200 でない場合、または LINE チャネル ID が正しくない場合、またはアクセストークンの有効期限が過ぎている場合にエラーをスローする。
 * @returns {Promise<void>} アクセストークンが有効であると確認された場合に解決する Promise.
 */

const verifyAccessToken = async (accessToken: string): Promise<void> => {
    // const response = await axios.get<LINEGetVerifyAPIResponse>(
    const response = await axios.get(
        `https://api.line.me/oauth2/v2.1/verify?access_token=${accessToken}`
    )
    if (response.status !== 200) {
        throw new Error(`[${response.status}]: GET /oauth2/v2.1/verify`)
    }
    const channelId = response.data.client_id
    if (channelId !== process.env.LINE_CHANNEL_ID) {
        throw new Error('LINE Login チャンネルIDが正しくありません。')
    }

    const expiresIn = response.data.expires_in
    if (expiresIn <= 0) {
        throw new Error('アクセストークンの有効期限が切れています。')
    }
}

/**
 * LINE のプロフィール情報を取得する。
 * @param {string} accessToken - LINE のアクセストークン。
 * @returns {Promise<{ lineUserId: string; name: string; imageUrl?: string }>} ユーザーの LINE ID、名前、画像URL（存在する場合）を含むオブジェクトを返す Promise.
 * @throws エラーが発生した場合、エラーメッセージが含まれる Error オブジェクトがスローされる。
 */

const getLINEProfile = async(accessToken: string): Promise<{lineUserId: string; name: string; imageUrl?: string}> => {
//     const response = await axios.get<LINEGetProfileResponse>('https://api.line.me/v2/profile', {headers: {Authorization: `Bearer ${accessToken}`}})
    const response = await axios.get('https://api.line.me/v2/profile', {headers: {Authorization: `Bearer ${accessToken}`}})
    if (response.status !== 200) {
        throw new Error(`[${response.status}]: GET /v2/profile`)
    }
    return {
        lineUserId: response.data.userId,
        name: response.data.displayName,
        imageUrl: response.data.pictureUrl
    }
}

/**
 * LINE のユーザー情報を使用して Firestore に 'users' ドキュメントを作成または更新する。
 * @param {Object} params - ユーザー情報パラメータ。
 * @param {string} params.lineUserId - LINE のユーザーID。
 * @param {string} params.name - LINE のユーザー名。
 * @param {string} [params.imageUrl] - LINE のユーザー画像のURL。提供されていない場合は null を設定する。
 * @returns {Promise<void>} 作成または更新操作が完了した後に解決する Promise.
 */

const setAppUserDocument = async ({lineUserId, name, imageUrl}: {lineUserId: string, name: string, imageUrl?: string }): Promise<void> => {
    await admin.firestore().collection('users').doc(lineUserId).set({
        name: name,
        image_path: imageUrl ?? null,
        created_time: Timestamp.now(),
        updated_time: Timestamp.now(),
        is_initial_access: true,
        email: '',
        group_id: null,
    })
}


