use ethabi::{decode, encode, Token};
use hex::decode as hex_decode;
use hex::encode as hex_encode;
use json::{object, JsonValue};
use std::env;
use std::time::Instant;

#[derive(Debug)]
enum OperationType {
    Add,
    Subtract,
    Divide,
    Multiply,
}

fn parse_operation_type(n: u8) -> Option<OperationType> {
    match n {
        0 => Some(OperationType::Add),
        1 => Some(OperationType::Subtract),
        2 => Some(OperationType::Divide),
        3 => Some(OperationType::Multiply),
        _ => None,
    }
}

pub async fn handle_advance(
    _client: &hyper::Client<hyper::client::HttpConnector>,
    _server_addr: &str,
    request: JsonValue,
) -> Result<&'static str, Box<dyn std::error::Error>> {
    println!("Received advance request data {}", &request);
    let _payload = request["data"]["payload"]
        .as_str()
        .ok_or("Missing payload")?;
    // TODO: add application logic here

    let modified_string = &_payload[2..];
    // remove_first_two_chars(&_payload);
    println!("payload without unnecesary content is: {}", modified_string);

    let bytes = hex_decode(modified_string).expect("Invalid hex");

    let tokens = decode(
        &[
            ethabi::ParamType::Uint(256), // firstNumber
            ethabi::ParamType::Uint(256), // secondNumber
            ethabi::ParamType::Uint(8),   // operation (as uint8)
        ],
        &bytes,
    )
    .expect("Failed to decode ABI");

    let first = tokens[0].clone().into_uint().unwrap();
    let second = tokens[1].clone().into_uint().unwrap();
    let op_raw = tokens[2].clone().into_uint().unwrap().as_u32() as u8;

    let op_type = parse_operation_type(op_raw).expect("Invalid operation type");
    let result = perform_operation(first.as_u128(), second.as_u128(), op_type);

    let result_hex = encode_tuple_to_hex(result);

    // Create a notice
    let notice = object! { "payload" => result_hex };
    let notice_request = hyper::Request::builder()
        .method(hyper::Method::POST)
        .uri(format!("{}/notice", _server_addr))
        .header("Content-Type", "application/json")
        .body(hyper::Body::from(notice.dump()))?;

    // Send the notice
    let _response = _client.request(notice_request).await?;
    Ok("accept")
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = hyper::Client::new();
    let server_addr = env::var("ROLLUP_HTTP_SERVER_URL")?;

    let mut status = "accept";
    loop {
        println!("Sending finish");
        let response = object! {"status" => status.clone()};
        let request = hyper::Request::builder()
            .method(hyper::Method::POST)
            .header(hyper::header::CONTENT_TYPE, "application/json")
            .uri(format!("{}/finish", &server_addr))
            .body(hyper::Body::from(response.dump()))?;
        let response = client.request(request).await?;
        println!("Received finish status {}", response.status());

        if response.status() == hyper::StatusCode::ACCEPTED {
            println!("No pending rollup request, trying again");
        } else {
            let body = hyper::body::to_bytes(response).await?;
            let utf = std::str::from_utf8(&body)?;
            let req = json::parse(utf)?;

            let request_type = req["request_type"]
                .as_str()
                .ok_or("request_type is not a string")?;
            status = match request_type {
                "advance_state" => handle_advance(&client, &server_addr[..], req).await?,
                &_ => {
                    eprintln!("Unknown request type");
                    "reject"
                }
            };
        }
    }
}

fn encode_tuple_to_hex(value: (Option<u128>, u128)) -> String {
    let tokens = vec![
        Token::Uint(value.0.expect("Error performing Calclation").into()),
        Token::Uint(value.1.into()),
    ];
    let encoded = encode(&tokens);

    format!("0x{}", hex_encode(encoded))
}

fn perform_operation(first: u128, second: u128, op_type: OperationType) -> (Option<u128>, u128) {
    let start = Instant::now();
    let result = match op_type {
        OperationType::Add => Some(first + second),
        OperationType::Subtract => Some(first - second),
        OperationType::Divide => {
            if second == 0 {
                None
            } else {
                Some(first / second)
            }
        }
        OperationType::Multiply => Some(first * second),
    };

    let duration_ms = start.elapsed().as_millis() as u128;

    return (result, duration_ms);
}
