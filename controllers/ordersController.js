const oracledb = require("oracledb");

const database = require("../services/database");

exports.read = async(req, res) => {
	const id = req.params.id;

	try {
		const dbResponse = await database.execute(
			`SELECT * 
			FROM ORDERS_ITEM
			WHERE ORDERS_ID = :ID
			`, {
				id: id
			}
		);

		console.log(dbResponse.rows);

		res.status(200).json(dbResponse.rows);

	} catch(err) {
		res.status(500).json({message: err.message});
	}
}

exports.readCustomer = async(req, res) => {
	const id = req.params.id;

	try {
		const dbResponse = await database.execute(
			`SELECT *
			FROM ORDERS
			WHERE CUSTOMER_ID = :ID
			`, {
				id: id
			}
		);

		console.log(dbResponse.rows);

		res.status(200).json(dbResponse.rows);
	} catch(err) {
		res.status(500).json({message: err.message});
	}
}

exports.readMerchant = async(req, res) => {
	const id = req.params.id;

	try {
		const dbResponse = await database.execute(
			`SELECT *
			FROM ORDERS
			WHERE MERCHANT_ID = :ID
			`, {
				id: id
			}
		);

		console.log(dbResponse.rows);

		res.status(200).json(dbResponse.rows);

	} catch(err) {
		res.status(500).json({message: err.message});
	}
}