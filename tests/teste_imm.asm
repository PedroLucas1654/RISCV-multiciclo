.text
.globl main
main:
    addi x1, x0, 10

    # ORI
    ori  x2, x1, 12
    sw   x2, 512(x0)
    ori  x2, x1, 0
    sw   x2, 516(x0)
    ori  x2, x1, -1
    sw   x2, 520(x0)
    ori  x2, x1, -2048
    sw   x2, 524(x0)
    ori  x2, x1, 2047
    sw   x2, 528(x0)

    # ANDI
    andi x2, x1, 12
    sw   x2, 532(x0)
    andi x2, x1, 0
    sw   x2, 536(x0)
    andi x2, x1, -1
    sw   x2, 540(x0)
    andi x2, x1, -2048
    sw   x2, 544(x0)
    andi x2, x1, 2047
    sw   x2, 548(x0)

    # XORI
    xori x2, x1, 12
    sw   x2, 552(x0)
    xori x2, x1, 0
    sw   x2, 556(x0)
    xori x2, x1, -1
    sw   x2, 560(x0)
    xori x2, x1, -2048
    sw   x2, 564(x0)
    xori x2, x1, 2047
    sw   x2, 568(x0)

    # ADDI
    addi x2, x1, 5
    sw   x2, 572(x0)
    addi x2, x1, -5
    sw   x2, 576(x0)
    addi x2, x1, 1024
    sw   x2, 580(x0)
    addi x2, x1, -2048
    sw   x2, 584(x0)
    addi x2, x1, 2047
    sw   x2, 588(x0)

    # x0 deve continuar zero
    addi x0, x1, 5
    sw   x0, 592(x0)

    # Operacoes do tipo R
    addi x3, x0, 12
    and  x2, x1, x3
    sw   x2, 596(x0)
    or   x2, x1, x3
    sw   x2, 600(x0)
    xor  x2, x1, x3
    sw   x2, 604(x0)

fim:
    jal x0, fim
