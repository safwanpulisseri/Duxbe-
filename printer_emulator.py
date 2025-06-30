#!/usr/bin/env python3
import socket
import threading
import binascii

def handle_printer_data(client_socket, address):
    print(f"Connection from {address}")
    
    while True:
        try:
            data = client_socket.recv(4096)
            if not data:
                break
            
            print(f"Received {len(data)} bytes:")
            print(f"Hex: {binascii.hexlify(data).decode()}")
            print(f"ASCII: {data.decode('ascii', errors='replace')}")
            print("-" * 50)
            
        except Exception as e:
            print(f"Error: {e}")
            break
    
    client_socket.close()
    print(f"Connection from {address} closed")

def start_printer_emulator(port=9100):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('localhost', port))
    server.listen(5)
    
    print(f"ESC/POS Printer Emulator listening on port {port}")
    print("Send printer data to localhost:9100")
    
    while True:
        try:
            client, address = server.accept()
            client_handler = threading.Thread(
                target=handle_printer_data, 
                args=(client, address)
            )
            client_handler.daemon = True
            client_handler.start()
        except KeyboardInterrupt:
            print("\nShutting down printer emulator...")
            break
    
    server.close()

if __name__ == "__main__":
    start_printer_emulator(8100)