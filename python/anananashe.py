import tkinter as tk
import time
import threading

class WeighingMixingSystem:
    def __init__(self, root):
        self.root = root
        self.root.title("Pesaje-Mezclado Automático (Demo)")
        
        self.canvas = tk.Canvas(root, width=700, height=500, bg="white")
        self.canvas.pack()
        
        # Dibujar tolvas A, B y C
        self.canvas.create_rectangle(50, 50, 120, 150, fill="lightblue", tags="A")
        self.canvas.create_text(85, 40, text="Tolva A")
        
        self.canvas.create_rectangle(150, 50, 220, 150, fill="lightgreen", tags="B")
        self.canvas.create_text(185, 40, text="Tolva B")
        
        self.canvas.create_rectangle(100, 200, 180, 250, fill="orange", tags="C")
        self.canvas.create_text(140, 190, text="Unidad C")
        
        # Mezclador N
        self.mixer = self.canvas.create_arc(400, 300, 500, 400, start=0, extent=180, fill="gray", tags="N")
        self.canvas.create_text(450, 290, text="Mezclador N")
        
        # Cinta transportadora
        self.canvas.create_rectangle(250, 100, 380, 120, fill="lightgray", tags="belt")
        self.canvas.create_text(315, 90, text="Cinta")
        
        # Botón start
        self.start_btn = tk.Button(root, text="Iniciar Ciclo", command=self.start_cycle)
        self.start_btn.pack(pady=10)
        
    def start_cycle(self):
        thread = threading.Thread(target=self.run_cycle)
        thread.start()
        
    def run_cycle(self):
        # Paso 1: Llenado de C desde A y B
        self.animate_fill("C", "blue", "A")
        self.animate_fill("C", "green", "B")
        
        # Paso 2: Transporte de 2 ladrillos
        for i in range(2):
            self.animate_brick()
        
        # Paso 3: Vaciar C en N
        self.animate_fill("N", "orange", "C")
        
        # Paso 4: Mezclar y volcar
        self.animate_mixer()
        
    def animate_fill(self, target, color, source):
        for i in range(5):
            self.canvas.create_rectangle(110, 210 - i*5, 170, 250 - i*5, fill=color, tags=f"fill_{target}_{i}")
            self.root.update()
            time.sleep(0.2)
        time.sleep(0.5)
        
    def animate_brick(self):
        brick = self.canvas.create_rectangle(250, 90, 270, 110, fill="brown")
        for x in range(250, 380, 5):
            self.canvas.move(brick, 5, 0)
            self.root.update()
            time.sleep(0.05)
        self.canvas.delete(brick)
        time.sleep(0.2)
        
    def animate_mixer(self):
        for angle in range(0, 360, 30):
            self.canvas.itemconfig(self.mixer, start=angle, extent=180)
            self.root.update()
            time.sleep(0.1)
        # Volcado final (animación simple)
        self.canvas.move(self.mixer, 50, 50)
        self.root.update()
        time.sleep(0.5)
        self.canvas.move(self.mixer, -50, -50)


if __name__ == "__main__":
    root = tk.Tk()
    app = WeighingMixingSystem(root)
    root.mainloop()
