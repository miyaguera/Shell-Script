#!/bin/bash

#--------------------------Configurações-------------------------------
DATA_=$(date +%d-%m-%y) # dd-mm-aa
#USUARIO="daniel.miyagi"
DOMINIO="@sec4you.com.br" #sintaxe = "@" + "dominio"
RESPOSTA="naoresponder" #usuario que aparecera quando clicar em responder
REMETENTE="monitoracao" # nome do usuario do remetente Ex: daniel.miyagi@sec4you.com.br = "daniel.miyagi"
NOME="4MON" # nome que sera exibido no E-mail, assim nao aparece o nome do usuario local
VERSAO="1.1"
U_AGENT="Miyaguera"
#--------------------------Configurações-------------------------------

DESTINATARIO="$1"
ASSUNTO="$2"
MSGM="$3"

#USUARIO="$DESTINATARIO"
#----------------- IMAGEM -----------------#
HOME_Z="/usr/local/share/zabbix/alertscripts"
HOME_IMG=""$HOME_Z"/imagens"
IMAGEM=""$HOME_IMG"/"$DESTINATARIO".png"
ARQUIVO=""$HOME_IMG"/logs/"$DESTINATARIO"+"$DATA_".log"
COOCKIE_Z=""$HOME_Z"/cookies.txt"
TRG_ID=$(echo "$ASSUNTO" | awk -F: {'print $4'} | sed s:\ ::g)
ITEM_ID=$(mysql -s -u zabbix -p'xxxxx' -e "select itemid from functions where triggerid = '"$TRG_ID"'" zabbix | tail -1)
GRAPH_ID=$(mysql -s -u zabbix -p'xxxx' -e "select graphid from graphs_items where itemid = '"$ITEM_ID"'" zabbix |tail -1)

date >> "$ARQUIVO"
echo "$ASSUNTO" >> "$ARQUIVO"
echo "DESTINATARIO = "$DESTINATARIO"" >> "$ARQUIVO"
echo "TRIGGERID_ITEMID = "$TRG_ID" "$ITEM_ID""  >> "$ARQUIVO"
#echo "ITEMID = "$ITEM_ID"" >> "$ARQUIVO"

if [ "0$GRAPH_ID" -eq "0" ] ; then
        echo "URL = http://monitoracao.sec4you.com.br/chart.php?itemid="$ITEM_ID"&width=574&height=124" >> "$ARQUIVO"
        wget --load-cookies="$COOCKIE_Z" -O "$IMAGEM" -q "monitoracao.sec4you.com.br/chart.php?itemid="$ITEM_ID"&width=574&height=124"
        IMGM=$(base64 "$IMAGEM")

else
        echo "GRPHID = $GRAPH_ID" >> "$ARQUIVO"
        echo "URL = http://monitoracao.sec4you.com.br/chart2.php?graphid="$GRAPH_ID"&width=574&height=124" >> "$ARQUIVO"

        wget --load-cookies="$COOCKIE_Z" -O "$IMAGEM" -q "monitoracao.sec4you.com.br/chart2.php?graphid="$GRAPH_ID"&width=574&height=124"
        IMGM=$(base64 "$IMAGEM")
fi

        echo "----------------------------------------------" >> "$ARQUIVO"
#----------------- IMAGEM -----------------#
MSGM_DIR=""$HOME_Z"/log_mensagem/"$DESTINATARIO""
echo "$MSGM" > "$MSGM_DIR"
MSGM2=$(grep "wiki.sec4you.com.br" "$MSGM_DIR" &> /dev/null || sed -i "s/.*sobre\ o\ item.*//" "$MSGM_DIR" && cat "$MSGM_DIR")

E_BOUNDARY="danielshinyumiyagi-j4p0n3g0"
echo -e "$MSGM2""\n\n""$IMGM""\n\n"""--$E_BOUNDARY"--" | mail \
        -a "Content-Type: multipart/related; boundary="$E_BOUNDARY"" \
        -a "MIME-Version: 1.0"\
        -a "X-Mailer: "$U_AGENT"-"$VERSAO"" \
        -a "Return-Path: "$REMETENTE""$DOMINIO"" \
        -a "Reply-To: "$RESPOSTA""$DOMINIO"" \
        -a "User-Agent: "$U_AGENT"-"$VERSAO"" \
        -a "X-SEC4YOU: Seu desafio e a nossa inspiracao" \
        -a "X-4MON: Alerta do servidor monitorado" \
        -s "$ASSUNTO" "$DESTINATARIO" -- -f "$REMETENTE" -F "$NOME"


#PREREQ
# possuir os comandos mail e sendmail

#CHANGELOG

# V0.1  01-01-2012      -> criado o script

# V0.2  02-02-2012      -> alterado o script para utilizar o comando mail
#                       -> adicionado o charset no header

# V0.3  03-02-2012      -> adicionado user-agent, x-mailer, x-sec4you e x-4mon dentro do header

# V0.4  09-02-2012      -> adicionado Return-Path e Reply-To para o E-mail ficar dentro do padrão da RFC822.
#                       -> adicionado a variavel $RESPOSTA e atribuida no Reply-To. Desta o E-mail será respondido para $RESPOSTA, que pode ser um e-mail invalido.
#                       -* O campo from e return-path está configurado com um E-mail válido para evitar problemas com anti-spams.
#                       -> cabeçalho MIME inserido para ficar dentro dos padrões da RFC 2045 - 2049. Headers extendidos.

# V0.5  20-03-2012      -> Alterado o content-type para montagem de E-mails com multiplos content-types.
#                       -> Inserido tambem um delimitador nas mensagens.

# V0.6  04-04-2012      -> Inserido imagem de gráfico no corpo da mensagem.


# V0.7  05-04-2012      -> Alterado o boundary de multipart/mixed para multipart/related, isso resolve o problema de compatibilidade com o thunderbird
#                       -> Solucionado problema de multiplos items para cada trigger
#                       -> Adicionado imagem para itens sem gráfico.

# V0.8  07-04-2012      -> Inserido gráficos para itens que nao possuem gráficos personalizados.

# V0.9  07-04-2012      -> Alterado o corpo da mensagem por questão de compatibilidade com o client de E-mail do IPAD.

# V1.0  26-06-2012      -> Alterado o local e o nome do arquivo de log.
#                       -> Alterado a variável USUARIO para separar os arquivos de log e imagens.

# V1.1  08-07-2012      -> Adicionado comandos para filtrar mensagens que não possuir {TRIGGER.URL}
#                       -> Corpo da mensagem alterado para inserir {TRIGGER.URL} 
