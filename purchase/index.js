const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);
const db = admin.firestore();
const userDoc = db.collection("stores");
const agentDocs = db.collection("storesOfStores");
const productDocs = db.collection("products");
const cardsDocs = db.collection("cards");
const d = new Date();
let userA = null;
let productA = null;
let agentA = null;
let totalPrice;
let finalPrice;
let listCards = [];
let commissionGroupName;
let commissionAdded;
let tobeCalled = true;
let agentId;
let cardsAvailable = false;

exports.buyCard =
    functions.runWith({
      timeoutSeconds: 12}).https.onRequest(async (request, response) => {
      console.log("started" + d.toLocaleTimeString());
      try {
        userDoc.doc(request.body.userid).get().then((user) => {
          if (user.exists) {
            userA = user;
            agentDocs.where("storesOfStores_storeId", "==", request.body.userid)
                .get()
                .then((agentRef) => {
                  const agentDoc =
              agentRef.docs.map((doc) => doc.data());
                  agentId =
              agentDoc[0].storesOfStores_representativesId;
                  userDoc.doc(agentId).get().then((agent) => {
                    if (agent.exists) {
                      agentA = agent;
                      if
                      (userA != null &&
                     agentA != null &&
                      productA != null &&
                       tobeCalled &&
                        cardsAvailable) {
                        tobeCalled = false;
                        calculateCost(request, response);
                      }
                    } else {
                      response.status(451).send("تم ايقاف الموزع");
                    }
                  });
                });
          } else {
            response.status(450).send("تم حذف حسابك الرجاء التواصل بالادارة");
          }
        });

        productDocs.doc(request.body.productid).get().then((product) => {
          if (product.exists) {
            productA = product;
            cardsDocs.where("card_productId", "==", request.body.productid)
                .where("card_sellingStatus", "==", "false")
                .where("card_status", "==", "true")
                .limit(
                    parseFloat(
                        request.body.gty))
                .get().then(
                    (cards) => {
                      //
                      listCards = [];
                      cards.docs.forEach((card) => {
                        listCards.push(card);
                      });
                      console.log("length is");
                      console.log(listCards.length);
                      if (listCards.length >= request.body.gty) {
                        cardsAvailable = true;
                        if (userA != null &&
                     agentA != null &&
                      productA != null &&
                       tobeCalled &&
                        cardsAvailable) {
                          tobeCalled = false;
                          calculateCost(request, response);
                        }
                      } else {
                        response
                            .status(470)
                            .send("الكمية غير متوفرة");
                      }
                    });
          } else {
            response
                .status(460)
                .send("المنتج غير متوفر");
          }
        });
      } catch (e) {
        response.status(100).send(e);
        throw e;
      }
    });
function calculateCost(request, response) {
  try {
    const groupValueNameOfAgent =
    agentA._fieldsProto.store_groupValue.stringValue;
    const productPrice =
    productA._fieldsProto[groupValueNameOfAgent].stringValue;
    const commissionDocs =
    db.collection("storesOfStoresPricesDifference");
    commissionDocs.
        where("storesOfStoresPricesDifference_storeid",
            "==",
            agentA._fieldsProto.store_id.stringValue)
        .where("storesOfStoresPricesDifference_productId",
            "==",
            request.body.productid)
        .get().then((commission) => {
          try {
            const agentCommissionDoc =
            commission.docs.map((doc) => doc.data());
            commissionGroupName =
            userA._fieldsProto.store_StoreOfStoresPriceName.stringValue;
            const agentCommisionDocMap =
            new Map(agentCommissionDoc.map((doc) => doc));
            if (agentCommisionDocMap
                .has(commissionGroupName)) {
              commissionAdded =
              agentCommissionDoc[0][commissionGroupName];
            } else {
              commissionAdded = 0;
            }
            totalPrice = parseFloat(productPrice) +
            parseFloat(commissionAdded);
            finalPrice = parseFloat(totalPrice) *
            parseFloat(request.body.gty);
            const userTotalBalance =
            parseFloat(userA._fieldsProto.store_debtBalance.stringValue) +
             parseFloat(userA._fieldsProto.store_cashBalance.stringValue);
            if (userTotalBalance >= finalPrice) {
              runTransaction(request, response);
            } else {
              response
                  .status(480)
                  .send("رصيدك غير كافي، المبلغ المطلوب" +
                  finalPrice +
                  "لديك " + userTotalBalance);
            }
          } catch (e) {
            response.status(500).send(e);
            throw e;
          }
        });
  } catch (e) {
    response.status(500).send(e);
    throw e;
  }
}
async function runTransaction(request, response) {
  try {
    const companyRf = db.collection("companies");
    const companyDoc = await companyRf
        .doc(productA._fieldsProto.product_companyId.stringValue)
        .get();
    let newUserTotalAfterPurchase;
    db.runTransaction(async (t) => {
      const userTotalBalance =
                parseFloat(userA._fieldsProto.store_cashBalance.stringValue) +
                parseFloat(userA._fieldsProto.store_debtBalance.stringValue);
      newUserTotalAfterPurchase =
      userTotalBalance - parseFloat(finalPrice);
      try {
        let newCashBalance;
        let newDebitBalance;
        if (
          parseFloat(userA._fieldsProto.store_cashBalance.stringValue) >=
            parseFloat(finalPrice)) {
          newCashBalance =
          parseFloat(userA._fieldsProto.store_cashBalance.stringValue) -
           parseFloat(finalPrice);
          newDebitBalance =
          parseFloat(userA._fieldsProto.store_debtBalance.stringValue);
        } else {
          newCashBalance = 0.0;
          newDebitBalance =
          parseFloat(userA._fieldsProto.store_cashBalance.stringValue)+
          parseFloat(userA._fieldsProto.store_debtBalance.stringValue)-
          parseFloat(finalPrice);
        }
        await t.update(
            userDoc.doc(userA.id),
            {
              store_cashBalance: newCashBalance.toString(),
              store_debtBalance: newDebitBalance.toString(),
            });
        console.log("user new balance is cash then debit");
        console.log(newCashBalance + newDebitBalance);
        console.log("user ref is" + userDoc.doc(userA.id));
      } catch (e) {
        response.status(402).send("userUpdateIssue" + e);
        throw e;
      }
      try {
        const datetime = d.getDate() + "/" +
                    (d.getMonth() + 1) + "/" +
                    d.getFullYear() + " @ " +
                    d.getHours() + ":" +
                    d.getMinutes() + ":" +
                    d.getSeconds();
        await listCards.forEach(async (index) => {
          console.log("buying ");
          console.log(index);
          // console.log(listCards[index].id);
          try {
            await t.update(
                cardsDocs.doc(index.id),
                {
                  card_BroughtPrice: totalPrice,
                  card_sellingStatus: true,
                  card_whoBroughtId: request.body.userid,
                  card_storeOfStoreId: agentId,
                  card_storeOfStoreProfit: commissionAdded,
                  card_productPrivatePrice:
                  productA._fieldsProto.product_groupFour_privatePrice
                      .stringValue,
                  card_broughtDate: datetime,
                  card_Quantity: request.body.gty,
                  card_balanceBefore: userTotalBalance.toString(),
                  card_balanceAfter:
                  newUserTotalAfterPurchase.toString(),
                  card_storeOfStoreRequestStatus: "nothing",
                },
            );
          } catch (e) {
            response.status(403).send("مشكلة داخلية بكود ٤٠٣" + e);
            throw e;
          }
        });
        return ("success");
      } catch (e) {
        response.status(403).send("مشكلة داخلية بكود ٤٠٣" + e);
        throw e;
      }
    }).then((res) => {
      const responses = {
        "success": res,
        "cardList": listCards,
        "company": companyDoc,
        "NewBalance": newUserTotalAfterPurchase.toString(),
      };
      response.send(responses);
      return (responses);
    });
  } catch (e) {
    response.status(500).send(e);
    throw e;
  }
}


exports.howMany =
    functions.https.onRequest(async (request, response) => {
      cardsDocs.where("card_productId", "==", request.body.productid)
          .where("card_sellingStatus", "==", "false")
          .where("card_status", "==", "true")
          .get().then(
              async (cards) => {
                //
                const allListCards = [];
                cards.docs.forEach((card) => {
                  allListCards.push(card);
                });
                const companyRf = db.collection("companies");
                const companyDoc = await companyRf
                    .doc(request.body.productid)
                    .get();
                console.log("company is");
                console.log(companyDoc);
                const responsee = {
                  "prolengthis": allListCards.length,
                  "compnayis": companyDoc.data(),
                };
                response.send(responsee);
              });
    });
